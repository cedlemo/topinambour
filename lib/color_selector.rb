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

TERMINAL_COLOR_NAMES = [:black, :red, :green, :yellow,
                        :blue, :magenta, :cyan, :white]

class TopinambourColorSelector < Gtk::Grid
  attr_reader :colors
  def initialize(window)
    @window = window
    super()

    reset_button = generate_reset_button
    attach(reset_button, 0, 0, 1, 1)

    initialize_default_colors
    add_color_selectors

    save_button = generate_save_button
    attach(save_button, 0, 1, 1, 1)

    import_button = generate_import_button
    attach(import_button, 10, 0, 1, 1)

    export_button = generate_export_button
    attach(export_button, 10, 1, 1, 1)

    show_all
    set_halign(:center)
    set_valign(:end)
    set_name("topinambour-color-selector")
  end

  private

  def generate_import_export_button(name)
    button = ColorSchemeSelector.new(name, @window)
    button.signal_connect "clicked" do |widget|
      filename = widget.run_chooser_dialog
      if filename then
        yield filename if block_given?
      end
      widget.chooser_destroy
    end
    button
  end

  def generate_import_button
    generate_import_export_button("Import") do |filename|
      file = File.read(filename)

      foreground = file[/\*\.foreground:\s*(.*)/, 1]
      child = get_child_at(1, 0)
      child.rgba = Gdk::RGBA.parse(foreground) unless foreground.nil?
      @colors[0] = child.rgba

      background = file[/\*\.background:\s*(.*)/, 1]
      child = get_child_at(1, 1)
      child.rgba =  Gdk::RGBA.parse(background) unless background.nil?
      @colors[1] = child.rgba
      #
      # Normal colors top row
      TERMINAL_COLOR_NAMES.each_with_index do |_, i|
        color = file[/\*\.color#{i}:\s*(.*)/, 1]
        child = get_child_at(2 + i, 0)
        child.rgba = Gdk::RGBA.parse(color) unless color.nil?
        @colors[2 + i] = child.rgba
      end

      # Bright colors bottom row
      TERMINAL_COLOR_NAMES.each_with_index do |_, i|
        color = file[/\*\.color#{i + 8}:\s*(.*)/, 1]
        child = get_child_at(2 + i, 1)
        child.rgba = Gdk::RGBA.parse(color) unless color.nil?
        @colors[10 + i] = child.rgba
      end
      apply_new_colors
    end
  end

  def generate_export_button
    generate_import_export_button("Export")
  end

  def initialize_default_colors
    colors_strings = @window.application.settings["colorscheme"]
    @default_colors = colors_strings.map {|c| Gdk::RGBA.parse(c) }
    @colors = @default_colors.dup
  end

  def generate_reset_button
    button = Gtk::Button.new(:label => "Reset")
    button.signal_connect "clicked" do
      initialize_default_colors
      # foreground
      get_child_at(1, 0).rgba = @default_colors[0]
      # background
      get_child_at(1, 1).rgba = @default_colors[1]

      # Normal colors top row
      TERMINAL_COLOR_NAMES.each_with_index do |_, i|
        get_child_at(2 + i, 0).rgba = @default_colors[2 + i]
      end

      # Bright colors bottom row
      TERMINAL_COLOR_NAMES.each_with_index do |_, i|
        get_child_at(2 + i, 1).rgba = @default_colors[10 + i]
      end
      apply_new_colors
    end
    button
  end

  def apply_new_properties
    colors_strings = @colors.map { |c| c.to_s }
    @window.application.settings["colorscheme"] = colors_strings
    @window.terminal.colors
    @window.terminal.load_settings
  end

  def generate_save_button
    button = Gtk::Button.new(:label => "Save")
    button.signal_connect "clicked" do |widget|
      apply_new_properties
      button.toplevel.exit_overlay_mode
    end
    button
  end

  def add_color_selector(name, i, position=nil)
    color_sel = Gtk::ColorButton.new(@default_colors[i])
    color_sel.title = name.to_s
    color_sel.name = "topinambour-button-#{name}"
    color_sel.tooltip_text = name.to_s
    color_sel.signal_connect "color-set" do
      @colors[i] = color_sel.rgba
      apply_new_colors
    end
    attach(color_sel, position[0], position[1], 1, 1)
  end

  def add_color_selectors
    add_color_selector("foreground", 0, [1, 0])
    add_color_selector("background", 1, [1, 1])
    TERMINAL_COLOR_NAMES.each_with_index do |name, i|
      add_color_selector(name, i + 2, [2 + i, 0])
    end

    TERMINAL_COLOR_NAMES.each_with_index do |name, i|
      add_color_selector("bright#{name}", i + 10, [2 + i, 1])
    end
  end

  def apply_new_colors
    @window.terminal.colors = @colors
  end
end

class ColorSchemeSelector < Gtk::Button
  def initialize(label, parent)
    @parent = parent
    super(:label => label)
  end

  def run_chooser_dialog
    @dialog = Gtk::FileChooserDialog.new(:title => label,
                                         :parent => @parent,
                                         :action => :open,
                                         :buttons => [[label, :ok],
                                                      ["Cancel", :cancel]])
    if @dialog.run == :ok then
      @dialog.filename
    end
  end

  def chooser_destroy
    @dialog.destroy
  end
end
