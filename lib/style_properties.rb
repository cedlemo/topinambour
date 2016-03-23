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

class TopinambourTerminal < Vte::Terminal
  extend TopinambourStyleProperties
  type_register
  TERMINAL_COLOR_NAMES.each_with_index do |c|
    name = c.to_s
    install_style("boxed",
                  name,
                  GLib::Type["GdkRGBA"])
  end
  install_style("boxed",
                "font",
                GLib::Type["PangoFontDescription"])
end

class TopinambourWindow < Gtk::ApplicationWindow
  extend TopinambourStyleProperties
  type_register
  install_style("string", "shell", "/usr/bin/fish")
  install_style("int", "width", [-1, 2000, 1000])
  install_style("int", "height", [-1, 2000, 500])
  install_style("string", "css-editor-style", "classic")
end
