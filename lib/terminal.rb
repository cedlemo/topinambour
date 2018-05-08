# Copyright 2015-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

class TopinambourTermBox < Gtk::Box
  attr_reader :term
  def initialize(command_string, working_dir = nil)
    super(:horizontal, 0)
    set_name("topinambour-term-box")
    @term = TopinambourTerminal.new(command_string, working_dir)
    @scrollbar = Gtk::Scrollbar.new(:vertical, @term.vadjustment)
    @scrollbar.name = "topinambour-scrollbar"
    pack_start(@term, :expand => true, :fill => true, :padding => 0)
    pack_start(@scrollbar)
    show_all
  end
end

##
# The default vte terminal customized
class TopinambourTerminal < Vte::Terminal
  attr_reader :pid, :menu
  REGEXES = [:REGEX_URL_AS_IS, :REGEX_URL_FILE, :REGEX_URL_HTTP,
                :REGEX_URL_VOIP, :REGEX_EMAIL, :REGEX_NEWS_MAN,
                :CSS_COLORS]

  ##
  # Create a new TopinambourTerminal instance that runs command_string
  def initialize(command_string, working_dir = nil)
    super()
    set_name("topinambour-terminal")
    command_array = parse_command(command_string)
    rescued_spawn(command_array, working_dir)

    signal_connect "child-exited" do |widget|
    end
    add_matches
    handle_mouse_clic
    set_size(180, 20)
  end

  def pid_dir
    File.readlink("/proc/#{@pid}/cwd")
  end

  def terminal_title
    @custom_title.class == String ? @custom_title : window_title.to_s
  end

  private

  def parse_command(command_string)
    GLib::Shell.parse(command_string)
  rescue GLib::ShellError => e
    STDERR.puts "domain  = #{e.domain}"
    STDERR.puts "code    = #{e.code}"
    STDERR.puts "message = #{e.message}"
  end

  def rescued_spawn(command_array, working_dir)
    @pid = spawn(:argv => command_array,
                 :working_directory => working_dir,
                 :spawn_flags => GLib::Spawn::SEARCH_PATH)
  rescue => e
    STDERR.puts e.message
  end

  def add_matches
    REGEXES.each do |name|
      regex_name = TopinambourRegex.const_get(name)
      flags = [:optimize,
               :multiline]
      if Vte::Regex
        # PCRE2_UTF | PCRE2_NO_UTF_CHECK | PCRE2_MULTILINE
        pcre2_utf = "0x00080000".to_i(16)
        pcre2_no_utf_check = "0x40000000".to_i(16)
        pcre2_multiline = "0x00000400".to_i(16)
        flags = pcre2_utf | pcre2_no_utf_check | pcre2_multiline
        regex = Vte::Regex.new(regex_name, flags, :for_match => true)
        match_add_regex(regex, 0)
      else
        regex = GLib::Regex.new(regex_name, :compile_options => flags)
        match_add_gregex(regex, 0)
      end
    end
  end

  def handle_mouse_clic
    signal_connect "button-press-event" do |widget, event|
      if event.type == Gdk::EventType::BUTTON_PRESS &&
         event.button == Gdk::BUTTON_SECONDARY
        manage_regex_on_right_click(widget, event)
        # display_copy_past_menu(widget, event)
        true
      elsif event.button == Gdk::BUTTON_PRIMARY
        manage_regex_on_click(widget, event)
        false # let false so that it doesn't block the event
      else
        false
      end
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
    case REGEXES[regex_type]
    when :REGEX_EMAIL
      launch_default_for_regex_match("mailto:" + match, REGEXES[regex_type])
    when :REGEX_URL_HTTP
      launch_default_for_regex_match("http://" + match, REGEXES[regex_type])
    when :CSS_COLORS
      launch_color_visualizer(match)
    else
      launch_default_for_regex_match(match, REGEXES[regex_type])
    end
  end

  def launch_default_for_regex_match(match, regex_type)
    Gio::AppInfo.launch_default_for_uri(match)
  rescue => e
    puts "error : #{e.message}\n\tfor match: #{match} of type :#{regex_type}"
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
