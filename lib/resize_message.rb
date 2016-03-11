# Copyright 2015-2016 Cédric LE MOIGNE, cedlemo@gmx.com
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
class TopinambourResizeMessage < Gtk::Box
  def initialize(text)
    super(:vertical)
    text ||= ""
    add(Gtk::Label.new(text))
    set_halign(:end)
    set_valign(:end)
    set_border_width(4)
    show_all
    set_name("resize_box")
  end

  def text=(text)
    children[0].text = text
    show_all
  end
end
