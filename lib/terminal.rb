# Copyright 2015-2016 Cedric LE MOIGNE, cedlemo@gmx.com
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

## The main full tab Gtk::Box + Vte::Terminal + Gtk::Scrollbar
#

class TopinambourTabTerm < Gtk::Box
  attr_reader :term
  def initialize(command_string, working_dir=nil)
    super(:horizontal, 0)
    set_name("topinambour-tab-term")
    @term = TopinambourTerminal.new(command_string, working_dir)
    @scrollbar = Gtk::Scrollbar.new(:vertical, @term.vadjustment)
    @scrollbar.name = "topinambour-scrollbar"
    pack_start(@term, :expand => true, :fill => true, :padding => 0)
    pack_start(@scrollbar)
  end
end
##
# The default vte terminal customized
class TopinambourTerminal < Vte::Terminal
  attr_reader :pid, :menu, :regexes, :last_match
  attr_accessor :preview, :custom_title

  ##
  # Create a new TopinambourTerminal instance that runs command_string
  def initialize(command_string, working_dir = nil)
    super()
    # TODO: make a begin/rescue like in glib2-2.2.4/sample/shell.rb
    command_array = GLib::Shell.parse(command_string)
    @pid = spawn(:argv => command_array,
                 :working_directory => working_dir,
                 :spawn_flags => GLib::Spawn::SEARCH_PATH)

    signal_connect "child-exited" do |widget|
      tabterm = widget.parent
      notebook = tabterm.parent
      current_page = notebook.page_num(tabterm)
      notebook.remove_page(current_page)
      @application.quit unless notebook.n_pages >= 1
    end

    signal_connect "window-title-changed" do |widget|
      tabterm = widget.parent
      notebook = tabterm.parent
      when_terminal_title_change if notebook && notebook.current.term == self
    end

    builder = Gtk::Builder.new(:resource =>
                               "/com/github/cedlemo/topinambour/terminal-menu.ui")
    @menu = Gtk::Popover.new(self, builder["termmenu"])

    signal_connect "button-press-event" do |widget, event|
      if event.type == Gdk::EventType::BUTTON_PRESS &&
         event.button == Gdk::BUTTON_SECONDARY
        manage_regex_on_right_click(widget, event)
        display_copy_past_menu(widget, event)
        true
      elsif event.button == Gdk::BUTTON_PRIMARY
        manage_regex_on_click(widget, event)
        false # let false so that it doesn't block the event
      else
        false
      end
    end

    configure
  end

  def pid_dir
    File.readlink("/proc/#{@pid}/cwd")
  end

  def terminal_title
    @custom_title.class == String ? @custom_title : window_title.to_s
  end

  def load_settings
    colors
    set_colors(@colors[0], @colors[1], @colors[2..-1])
    set_font(font)
  end

  def colors
    colors_strings = application.settings["colorscheme"]
    @colors = colors_strings.map {|c| Gdk::RGBA.parse(c) }
    @colors
  end

  def font
    font_str = application.settings["font"]
    @font = Pango::FontDescription.new(font_str)
  end

  def colors=(colors)
    set_colors(colors[0], colors[1], colors[2..-1])
  end

  def font=(font_str)
    application.settings["font"] = Pango::FontDescription.new(font_str)
    set_font(font)
    @font = font
  end

  def application
    @application = self.parent.toplevel.application unless @application
    @application
  end

  private

  def configure
    set_rewrap_on_resize(true)
    set_scrollback_lines(-1)
    search_set_wrap_around(true)
    add_matches
  end

  def add_matches
    @regexes = [:REGEX_URL_AS_IS, :REGEX_URL_FILE, :REGEX_URL_HTTP,
                :REGEX_URL_VOIP, :REGEX_EMAIL, :REGEX_NEWS_MAN,
                :CSS_COLORS]
    @regexes.each do |name|
      regex_name = TopinambourRegex.const_get(name)
      flags = [GLib::RegexCompileFlags::OPTIMIZE,
               GLib::RegexCompileFlags::MULTILINE]
      regex = GLib::Regex.new(regex_name, :compile_options => flags)
      match_add_gregex(regex, 0)
    end
  end

  def display_copy_past_menu(widget, event)
    x, y = event.window.coords_to_parent(event.x,
                                         event.y)
    rect = Gdk::Rectangle.new(x - allocation.x,
                              y - allocation.y,
                              1,
                              1)
    widget.menu.set_pointing_to(rect)
    widget.menu.show
  end

  def manage_regex_on_right_click(_widget, event)
    @last_match, _regex_type = match_check_event(event)
  end

  def manage_regex_on_click(_widget, event)
    match, regex_type = match_check_event(event)
    return nil if regex_type == -1
    case @regexes[regex_type]
    when :REGEX_EMAIL
      launch_default_for_regex_match("mailto:" + match, @regexes[regex_type])
    when :REGEX_URL_HTTP
      launch_default_for_regex_match("http://" + match, @regexes[regex_type])
    when :CSS_COLORS
      launch_color_visualizer(match)
    else
      launch_default_for_regex_match(match, @regexes[regex_type])
    end
  end

  def when_terminal_title_change
    parent.toplevel.current_label.text = terminal_title
  end

  def launch_default_for_regex_match(match, regex_type)
    begin
      Gio::AppInfo.launch_default_for_uri(match)
    rescue => e
      puts "error : #{e.message}\n\tfor match: #{match} of type :#{regex_type}"
    end
  end

  def launch_color_visualizer(color_name)
    dialog = Gtk::ColorChooserDialog.new(:title => color_name,
                                         :parent => parent.toplevel)
    dialog.show_editor = true
    dialog.use_alpha = true
    dialog.rgba = Gdk::RGBA.parse(color_name)
    if dialog.run == Gtk::ResponseType::OK
      clipboard = Gtk::Clipboard.get_default(Gdk::Display.default)
      clipboard.text = dialog.rgba.to_s
    end
    dialog.destroy
  end
end
