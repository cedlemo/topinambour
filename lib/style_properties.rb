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

module TopinambourStyleProperties
  def generate_string_rw_property(name, args)
    GLib::Param::String.new(name.downcase,
                            name.capitalize,
                            name.upcase,
                            args,
                            GLib::Param::READABLE |
                            GLib::Param::WRITABLE)
  end

  def generate_boolean_rw_property(name, args)
    GLib::Param::Boolean.new(name.downcase,
                             name.capitalize,
                             name.upcase,
                             args,
                             GLib::Param::READABLE |
                             GLib::Param::WRITABLE)
  end

  def generate_int_rw_property(name, args)
    GLib::Param::Int.new(name.downcase,
                         name.capitalize,
                         name.upcase,
                         *args,
                         GLib::Param::READABLE |
                         GLib::Param::WRITABLE)
  end

  def generate_enum_rw_property(name, args)
    GLib::Param::Enum.new(name.downcase,
                          name.capitalize,
                          name.upcase,
                          *args,
                          GLib::Param::READABLE |
                          GLib::Param::WRITABLE)
  end

  def generate_boxed_rw_property(name, args)
    GLib::Param::Boxed.new(name.downcase,
                           name.capitalize,
                           name.upcase,
                           args,
                           GLib::Param::READABLE |
                           GLib::Param::WRITABLE)
  end

  def generate_rw_property(type, name, args)
    type = type.to_s.downcase
    method_name = "generate_#{type}_rw_property"
    return false unless methods.include?(method_name.to_sym)
    method(method_name.to_sym).call(name, args)
  end

  def install_style(type, name, args)
    property = generate_rw_property(type, name, args)
    install_style_property(property) if property
  end
end

TERMINAL_COLOR_NAMES = [:foreground, :background, :black, :red, :green, :yellow,
                        :blue, :magenta, :cyan, :white, :brightblack,
                        :brightred, :brightgreen, :brightyellow, :brightblue,
                        :brightmagenta, :brightcyan, :brightwhite
                       ]
DEFAULT_TERMINAL_COLORS = %w(#aeafad #323232 #000000 #b9214f #A6E22E #ff9800
                             #3399ff #8e33ff #06a2dc #B0B0B0 #5D5D5D #ff5c8d
                             #CDEE69 #ffff00 #9CD9F0 #FBB1F9 #77DFD8 #F7F7F7)
DEFAULT_TERMINAL_FONT = "Monospace 11"

class TopinambourTerminal < Vte::Terminal
  extend TopinambourStyleProperties
  type_register
  TERMINAL_COLOR_NAMES.each_with_index do |c|
    name = c.to_s
    install_style("boxed",
                  name,
                  GLib::Type["GdkRGBA"])
  end
  install_style("boxed", "font",
                GLib::Type["PangoFontDescription"])
  install_style("boolean", "audible-bell", false)
  install_style("boolean", "allow-bold", true)
  install_style("boolean", "scroll-on-output", true)
  install_style("boolean", "scroll-on-keystroke", true)
  install_style("boolean", "rewrap-on-resize", true)
  install_style("boolean", "mouse-autohide", true)
  install_style("enum", "cursor-shape", [GLib::Type["VteCursorShape"],
                                         Vte::CursorShape::BLOCK])
  install_style("enum", "cursor-blink-mode", [GLib::Type["VteCursorBlinkMode"],
                                         Vte::CursorBlinkMode::SYSTEM])
  install_style("enum", "backspace-binding", [GLib::Type["VteEraseBinding"],
                                              Vte::EraseBinding::AUTO])
  install_style("enum", "delete-binding", [GLib::Type["VteEraseBinding"],
                                           Vte::EraseBinding::AUTO])
  def load_properties
    %w(audible_bell allow_bold scroll_on_output scroll_on_keystroke
       rewrap_on_resize mouse_autohide).each do |prop|
      send("#{prop}=", style_get_property(prop.gsub(/_/,"-")))
    end
    %w(cursor_shape cursor_blink_mode backspace_binding delete_binding).each do |prop|
      send("#{prop}=", style_get_property(prop.gsub(/_/,"-")))
    end
    @colors = css_colors
    apply_colors
    set_font(css_font)
  end

  def parse_css_color(color_name)
    color_index = TERMINAL_COLOR_NAMES.index(color_name.to_sym)
    color_value = DEFAULT_TERMINAL_COLORS[color_index]
    default_color = Gdk::RGBA.parse(color_value)
    color_from_css = style_get_property(color_name)
    color = color_from_css ? color_from_css : default_color
    color
  end

  def css_colors
    colors = []
    background = parse_css_color(TERMINAL_COLOR_NAMES[0].to_s)
    foreground = parse_css_color(TERMINAL_COLOR_NAMES[1].to_s)
    TERMINAL_COLOR_NAMES[2..-1].each do |c|
      colors << parse_css_color(c.to_s)
    end
    [background, foreground] + colors
  end

  def css_font
    font = style_get_property("font")
    font = Pango::FontDescription.new(DEFAULT_TERMINAL_FONT) unless font
    font
  end

  def apply_colors
    set_colors(@colors[0], @colors[1], @colors[2..-1])
  end
end

class TopinambourWindow < Gtk::ApplicationWindow
  extend TopinambourStyleProperties
  type_register
  install_style("string", "shell", "/usr/bin/fish")
  install_style("int", "width", [-1, 2000, 1000])
  install_style("int", "height", [-1, 2000, 500])

  def load_properties

  end
end
