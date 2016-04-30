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
require "gtksourceview3"

class TopinambourPreferences < Gtk::Dialog
  def initialize(options)
    super(options)
    set_border_width(10)
    pane = Gtk::Paned.new(:horizontal)
    window_props = Gtk::Box.new(:vertical)
    window_props.vexpand = false
    term_props = Gtk::Box.new(:vertical)
    term_props.vexpand =false
    pane.pack1(in_frame(window_props, "General Properties"),
               :resize => true, :shrink => true)
    pane.pack2(in_frame(term_props, "Terminals Properties"),
               :reisze => true, :shrink => true)
    
    content_area.add(pane)
    shell_label = gen_custom_label("Shell")

    window_props.pack_start(shell_label, :expand => true,
                            :fill => true, :padding => 0)
    shell_entry = Gtk::Entry.new
    shell_entry.vexpand = false
    shell_entry.valign = :start
    
    window_props.pack_start(shell_entry, :expand => true,
                            :fill => true, :padding => 0)
    width_label = gen_custom_label("Width")
    window_props.pack_start(width_label, :expand => true,
                            :fill => true, :padding => 0)
    width_spin = Gtk::SpinButton.new(0, 1000, 5)
    width_spin.vexpand = false
    width_spin.valign = :start
    width_spin.halign = :end
    window_props.pack_start(width_spin, :expand => true,
                            :fill => true, :padding => 0)
    height_label = gen_custom_label("Height")
    window_props.pack_start(height_label, :expand => true,
                            :fill => true, :padding => 0)
    height_spin = Gtk::SpinButton.new(0, 1000, 5)
    height_spin.vexpand = false
    height_spin.halign = :end
    height_spin.valign = :start

    window_props.pack_start(height_spin, :expand => true,
                            :fill => true, :padding => 0)
    editor_style_label = gen_custom_label("Css Editor Style")
    window_props.pack_start(editor_style_label, :expand => true,
                            :fill => true, :padding => 0)
    editor_style_chooser = GtkSource::StyleSchemeChooserButton.new
    editor_style_chooser.vexpand = false
    editor_style_chooser.valign = :start

    window_props.pack_start(editor_style_chooser, :expand => true,
                            :fill => true, :padding => 0)
  
    audible_bell_label = gen_custom_label("Audible Bell")
    term_props.pack_start(audible_bell_label, :expand => true,
                            :fill => true, :padding => 0)
    audible_bell_switch = Gtk::Switch.new
    audible_bell_switch.halign = :end
    audible_bell_switch.hexpand = false

    term_props.pack_start(audible_bell_switch, :expand => true,
                            :fill => true, :padding => 0)
    allow_bold_label = gen_custom_label("Allow Bold")
    term_props.pack_start(allow_bold_label, :expand => true,
                            :fill => true, :padding => 0)
    allow_bold_switch = Gtk::Switch.new
    allow_bold_switch.halign = :end
    allow_bold_switch.hexpand = false
    term_props.pack_start(allow_bold_switch, :expand => true,
                            :fill => true, :padding => 0)
    scroll_on_output_label = gen_custom_label("Scroll On Output")
    term_props.pack_start(scroll_on_output_label, :expand => true,
                            :fill => true, :padding => 0)
    scroll_on_output_switch = Gtk::Switch.new
    scroll_on_output_switch.halign = :end
    scroll_on_output_switch.hexpand = false

    term_props.pack_start(scroll_on_output_switch, :expand => true,
                            :fill => true, :padding => 0)
    scroll_on_keystroke_label = gen_custom_label("Scroll On Keystroke")
    term_props.pack_start(scroll_on_keystroke_label, :expand => true,
                            :fill => true, :padding => 0)
    scroll_on_keystroke_switch = Gtk::Switch.new
    scroll_on_keystroke_switch.halign = :end
    scroll_on_keystroke_switch.hexpand = false

    term_props.pack_start(scroll_on_keystroke_switch, :expand => true,
                            :fill => true, :padding => 0)
    rewrap_on_resize_label = gen_custom_label("Rewrap On Resize")
    term_props.pack_start(rewrap_on_resize_label, :expand => true,
                            :fill => true, :padding => 0)
    rewrap_on_resize_switch = Gtk::Switch.new
    rewrap_on_resize_switch.halign = :end
    rewrap_on_resize_switch.hexpand = false
    term_props.pack_start(rewrap_on_resize_switch, :expand => true,
                            :fill => true, :padding => 0)
    mouse_autohide_label = gen_custom_label("Mouse Autohide")
    term_props.pack_start(mouse_autohide_label, :expand => true,
                            :fill => true, :padding => 0)
    mouse_autohide_switch = Gtk::Switch.new
    mouse_autohide_switch.hexpand = false
    mouse_autohide_switch.halign = :end
    term_props.pack_start(mouse_autohide_switch, :expand => true,
                            :fill => true, :padding => 0)
  end
  
  private

  def in_frame(box, name)
    frame = Gtk::Frame.new(name)
    frame.set_size_request(400, 250)
    frame.border_width = 5
    frame.add(box)
    frame.vexpand = false
    frame.valign = :start
    frame.show
    frame
  end
  
  def gen_custom_label(string)
    label = Gtk::Label.new(string)
    label.valign = :start
    label.halign = :start
    label.vexpand = false
    label
  end
end
