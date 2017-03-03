# Copyright 2015-2017 Cedric LE MOIGNE, cedlemo@gmx.com
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

TERMINAL_COLOR_NAMES = [:foreground, :background, :black, :red, :green, :yellow,
                        :blue, :magenta, :cyan, :white, :brightblack,
                        :brightred, :brightgreen, :brightyellow, :brightblue,
                        :brightmagenta, :brightcyan, :brightwhite
                       ]

class TopinambourColorSelector < Gtk::Box
  attr_reader :colors
  def initialize(window)
    @window = window
    super(:horizontal, 0)

    reset_button = generate_reset_button
    pack_start(reset_button, :expand => false, :fill => false, :padding => 0)

    initialize_default_colors
    add_color_selectors

    save_button = generate_save_button
    pack_start(save_button, :expand => false, :fill => false, :padding => 0)

    show_all
    set_halign(:center)
    set_valign(:end)
    set_name("color_selector")
  end

  private

  def initialize_default_colors
    colors_strings = @window.application.settings["colorscheme"]
    @default_colors = colors_strings.map {|c| Gdk::RGBA.parse(c) }
    @colors = @default_colors.dup
  end

  def generate_reset_button
    button = Gtk::Button.new(:label => "Reset")
    button.signal_connect "clicked" do
      initialize_default_colors
      children[1..-2].each_with_index do |child, i|
        child.rgba = @default_colors[i]
      end
      apply_new_colors
    end
    button
  end

  def apply_new_properties
    colors_strings = @colors.map { |c| c.to_s }
    @window.application.settings["colorscheme"] = colors_strings
    @window.notebook.send_to_all_terminals(:colors, nil)
    @window.notebook.send_to_all_terminals(:load_settings, nil)
  end

  def generate_save_button
    button = Gtk::Button.new(:label => "Save")
    button.signal_connect "clicked" do |widget|
      apply_new_properties
      button.toplevel.exit_overlay_mode
    end
    button
  end

  def add_color_selectors
    TERMINAL_COLOR_NAMES.each_with_index do |name, i|
      color_sel = Gtk::ColorButton.new(@default_colors[i])
      color_sel.title = name.to_s
      color_sel.tooltip_text = name.to_s
      color_sel.signal_connect "color-set" do
        @colors[i] = color_sel.rgba
        apply_new_colors
      end
      pack_start(color_sel, :expand => false, :fill => false, :padding => 0)
    end
  end

  def apply_new_colors
    @window.notebook.current.term.colors = @colors
  end
end
