# Copyright 2016 Cédric LE MOIGNE, cedlemo@gmx.com
# This file is part of Topinambour.
#
# Topinambour is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# Topinambour is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Topinambour.  If not, see <http://www.gnu.org/licenses/>.

class TopinambourApplication < Gtk::Application
  attr_reader :provider
  def initialize
    super("com.github.cedlemo.topinambour", :non_unique)

    signal_connect "startup" do |application|
      load_css_config
      screen = Gdk::Display.default.default_screen
      Gtk::StyleContext.add_provider_for_screen(screen, @provider, Gtk::StyleProvider::PRIORITY_USER)
      TopinambourActions.add_actions_to(application)
      load_menu_ui_in(application)
    end

    signal_connect "activate" do |application|
      window = TopinambourWindow.new(application)
      window.present
      window.add_terminal
      window.notebook.current.grab_focus
    end
  end

  def update_css(new_props = nil)
    css_properties
    @props.merge!(new_props) if new_props
    css = update_css_properties
    merged_css = Sass::Engine.new(css, :syntax => :scss).render
    if File.exist?(USR_CSS)
      FileUtils.mv(USR_CSS, "#{USR_CSS}_#{Time.new.strftime('%Y-%m-%d-%H-%M-%S')}.backup")
      File.open(USR_CSS, "w") do |file|
        file.puts merged_css
      end
    else
      File.open(USR_CSS, "w") do |file|
        file.puts merged_css
      end
    end
  end

  private

  def load_menu_ui_in(application)
    builder = Gtk::Builder.new(:resource => "/com/github/cedlemo/topinambour/app-menu.ui")
    app_menu = builder["appmenu"]
    application.app_menu = app_menu
  end

  def load_css_config
    @provider = Gtk::CssProvider.new
    default_css = Gio::Resources.lookup_data("/com/github/cedlemo/topinambour/topinambour.css", 0)
    if File.exist?(USR_CSS)
      begin
        @provider.load(:path => USR_CSS)
      rescue
        puts "Bad css file using default css"
        @provider.load(:data => default_css)
      end
    else
      puts "No custom CSS, using default css"
      @provider.load(:data => default_css)
    end
  end

  def load_css_to_tree
    engine = Sass::Engine.new(@provider.to_s, :syntax => :scss)
    engine.to_tree
  end

  def update_css_properties
    modified_sass = change_existing_properties
    sass_to_add = @props.empty? ? "" : add_new_css_properties
    Sass::Engine.new(sass_to_add + modified_sass, :syntax => :sass).render
  end

  def add_new_css_properties
    new_sass = "*"
    @props.each do |k, v|
      new_sass += "\n  #{k}: #{v}"
    end
    new_sass + "\n"
  end

  def change_existing_properties
    keys_found = []
    tree = load_css_to_tree
    # we search for properties that are already configured
    tree.children.each do |node|
      node.each do |prop|
        next if prop.class != Sass::Tree::PropNode
        name = prop.name[0]
        next unless @props[name]
        keys_found << name unless keys_found.include?(name)
        if @props[name] != prop.value.value
          value_object = prop.value.value.class.new(@props[name])
          prop.value = Sass::Script::Tree::Literal.new(value_object)
        end
      end
    end
    keys_found.each do |k|
      @props.delete(k)
    end
    tree.to_sass
  end

  def css_properties
    @props = {}
    return @props if windows[0].notebook.current.class == TopinambourTerminal

    terminal_colors = windows[0].notebook.current.colors
    TERMINAL_COLOR_NAMES.each_with_index do |c, i|
      @props["-TopinambourTerminal-#{c}"] = terminal_colors[i].to_s
    end
    @props["-TopinambourTerminal-font"] = DEFAULT_TERMINAL_FONT
    @props["-TopinambourWindow-shell"] = "\'/usr/bin/fish\'"
  end
end
