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
class TopinambourFontSelector < Gtk::Box
  attr_reader :font
  def initialize(window)
    @window = window
    @font = @window.notebook.current.font
    super(:horizontal, 0)

    reset_button = Gtk::Button.new(:label => "Reset")
    reset_button.signal_connect "clicked" do
      font_desc = Pango::FontDescription.new(@font)
      @window.notebook.current.set_font(font_desc)
    end
    pack_start(reset_button, :expand => false, :fill => false, :padding => 0)

    font_button = Gtk::FontButton.new
    font_button.set_font(@font)
    font_button.set_show_style(true)
    font_button.set_show_size(true)
    font_button.set_use_font(true)
    font_button.set_use_size(false)
    font_button.signal_connect "font-set" do
      font_desc = Pango::FontDescription.new(font_button.font_name)
      @window.notebook.current.set_font(font_desc)
    end
    pack_start(font_button, :expand => false, :fill => false, :padding => 0)

    save_button = Gtk::Button.new(:label => "Save")
    save_button.signal_connect "clicked" do
      new_props = {}
      font = @window.notebook.current.font
      new_props["-TopinambourTerminal-font"] = font.to_s
      toplevel.application.update_css(new_props)
      toplevel.notebook.send_to_all_terminals("set_font", font)
      toplevel.exit_overlay_mode
    end
    pack_start(save_button, :expand => false, :fill => false, :padding => 0)
    set_name("font_selector")
    show_all
    set_halign(:center)
    set_valign(:end)
  end
end
