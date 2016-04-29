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
                             #CDEE69 #ffff00 #9CD9F0 #FBB1F9 #77DFD8 #F7F7F7
                            )
DEFAULT_TERMINAL_FONT = "Monospace 11"

# boolean :
#
# VteCursorShape :
# cursor_shape
#   VTE_CURSOR_SHAPE_BLOCK      Draw a block cursor. This is the default.
#   VTE_CURSOR_SHAPE_IBEAM      Draw a vertical bar on the left side of character. 
#                               This is similar to the default cursor for other GTK+ widgets.
#   VTE_CURSOR_SHAPE_UNDERLINE  Draw a horizontal bar below the character.
#
# VteCursorBlinkMode
#  cursor_blink_mode
#   VTE_CURSOR_BLINK_SYSTEM Follow GTK+ settings for cursor blinking.
#   VTE_CURSOR_BLINK_ON     Cursor blinks.
#   VTE_CURSOR_BLINK_OFF    Cursor does not blink.
#
# VteEraseBinding
#  backspace_binding
#  delete_binding
#    VTE_ERASE_AUTO For backspace, attempt to determine the right value from the 
#                   terminal's IO settings. For delete, use the control sequence.
#    VTE_ERASE_ASCII_BACKSPACE Send an ASCII backspace character (0x08).
#    VTE_ERASE_ASCII_DELETE    Send an ASCII delete character (0x7F).
#    VTE_ERASE_DELETE_SEQUENCE Send the "@7 " control sequence.
#    VTE_ERASE_TTY             Send terminal's "erase" setting.

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
  install_style("boolean", "audible_bell", false)
  install_style("boolean", "allow_bold", true)
  install_style("boolean", "scroll_on_output", true)
  install_style("boolean", "scroll_on_keystroke", true)
  install_style("boolean", "rewrap_on_resize", true)
  install_style("boolean", "mouse_autohide", true)
end

class TopinambourWindow < Gtk::ApplicationWindow
  extend TopinambourStyleProperties
  type_register
  install_style("string", "shell", "/usr/bin/fish")
  install_style("int", "width", [-1, 2000, 1000])
  install_style("int", "height", [-1, 2000, 500])
  install_style("string", "css-editor-style", "classic")
end
