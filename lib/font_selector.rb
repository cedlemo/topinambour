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

## Widget used to choose the font at runtime in a Gtk::Layout
#
class TopinambourFontSelector < Gtk::Box
  attr_reader :font
  def initialize(window)
    super(:horizontal, 0)
    configure
    @window = window
    @font = @window.terminal.font
    add_buttons
    show_all
  end

  private

  def configure
    set_name('topinambour-font-selector')
    set_halign(:center)
    set_valign(:end)
  end

  def generate_reset_button
    @reset_button = Gtk::Button.new(label: 'Reset')
    @reset_button.signal_connect 'clicked' do
      @window.terminal.font = @font.to_s
    end
  end

  def generate_font_button
    @font_button = Gtk::FontButton.new
    @font_button.font = @font.to_s
    @font_button.show_style = true
    @font_button.show_size = true
    @font_button.use_font = true
    @font_button.use_size = false
    @font_button.signal_connect 'font-set' do
      @window.terminal.font = @font_button.font_name
    end
  end

  def generate_save_button
    @save_button = Gtk::Button.new(label: 'Quit')
    @save_button.signal_connect 'clicked' do
      @window.overlay.exit_overlay_mode
    end
  end

  def add_buttons
    generate_reset_button
    pack_start(@reset_button, expand: false, fill: false, padding: 0)
    generate_font_button
    pack_start(@font_button, expand: false, fill: false, padding: 0)
    generate_save_button
    pack_start(@save_button, expand: false, fill: false, padding: 0)
  end
end
