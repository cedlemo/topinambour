# Copyright 2016 Cedric LE MOIGNE, cedlemo@gmx.com
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
  attr_reader :provider, :css_file, :css_content # :css_content really needed ?
  def initialize
    super("com.github.cedlemo.topinambour", :non_unique)

    signal_connect "startup" do |application|
      load_css_config
      screen = Gdk::Display.default.default_screen
      Gtk::StyleContext.add_provider_for_screen(screen,
                                                @provider,
                                                Gtk::StyleProvider::PRIORITY_USER)
      TopinambourActions.add_actions_to(application)
      load_menu_ui_in(application)
    end

    signal_connect "activate" do |application|
      window = TopinambourWindow.new(application)
      window.present
      window.add_terminal
      window.notebook.current.term.grab_focus
    end
  end

  def update_css(new_props)
    props = []
    new_props.each do |prop|
      props << {:name => prop[0], :value => prop[1]}
    end
    new_css = CssHandler.update_css(@css_file, props)
    replace_old_conf_with(new_css)

    begin
      load_custom_css_config
    rescue => e
      puts "Bad css file using default css, #{e.message}"
      load_default_css_config # Use last workin Css instead
    end
  end

  def replace_old_conf_with(new_conf)
    if File.exist?(USR_CSS)
      new_name = "#{USR_CSS}_#{Time.new.strftime('%Y-%m-%d-%H-%M-%S')}.backup"
      FileUtils.mv(USR_CSS, new_name)
    end
    check_and_create_if_no_config_dir
    File.open(USR_CSS, "w") do |file|
      file.puts new_conf
    end
    @css_content = new_conf
  end


  def reload_css_config
    if File.exist?(USR_CSS)
      @provider.signal_connect "parsing-error" do |_css_provider, section, error|
      puts "error"
      # @start_i = @view.buffer.get_iter_at(:line => section.start_line,
      #                                    :index => section.start_position)
      # @end_i =  @view.buffer.get_iter_at(:line => section.end_line,
      #                                   :index => section.end_position)
      # if error == Gtk::CssProviderError::DEPRECATED
      # else
      end
      load_custom_css_config
    else
      write_down_default_css
    end
  end

  private

  def load_menu_ui_in(application)
    builder = Gtk::Builder.new(:resource => "/com/github/cedlemo/topinambour/app-menu.ui")
    app_menu = builder["appmenu"]
    application.app_menu = app_menu
  end

  def load_default_css_config
    @css_content = Gio::Resources.lookup_data("/com/github/cedlemo/topinambour/topinambour.css", 0)
    @css_file = "#{DATA_PATH}/topinambour.css"
    @provider.load(:data => @css_content)
  end

  def load_custom_css_config
    @css_content = File.open(USR_CSS, "r").read
    @css_file = USR_CSS
    @provider.load(:data => @css_content)
  end

  def load_css_config
    @provider = Gtk::CssProvider.new
    if File.exist?(USR_CSS)
      begin
        load_custom_css_config
      rescue => e
        puts "Bad css file using default css #{e.message}"
        load_default_css_config
      end
    else
      puts "No custom CSS, using default css"
      load_default_css_config
    end
  end

  def write_down_default_css
    File.open(USR_CSS, "w") { |file| file.write(@css_content) }
  end

  def check_and_create_if_no_config_dir
    Dir.mkdir(CONFIG_DIR) unless Dir.exist?(CONFIG_DIR)
  end
end
