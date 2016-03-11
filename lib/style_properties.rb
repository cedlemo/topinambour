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
