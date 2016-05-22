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

module TopinambourPreferences
  def self.generate_dialog(parent)
    resource_file = "/com/github/cedlemo/topinambour/prefs-dialog.ui"
    builder = Gtk::Builder.new(:resource => resource_file)
    dialog = builder["Preferences_dialog"]
    dialog.transient_for = parent
    add_source_view_style_chooser(builder, parent)
    add_actions(builder, parent)
    connect_response(dialog, builder)
    dialog
  end

  def self.connect_response(dialog, builder)
    dialog.signal_connect "response" do |widget, response|
      case response
      when 0
        on_ok_response(widget, builder)
      when 1
        on_apply_response(widget, builder)
      when 2
        on_cancel_response(widget)
      else
        on_other_response(widget)
      end
    end
  end

  def self.on_ok_response(widget, builder)
    props = on_apply_response(widget, builder)
    toplevel = widget.transient_for
    toplevel.application.update_css(props)
    widget.destroy
  end

  def self.on_apply_response(widget, builder)
    toplevel = widget.transient_for
    props = {}

    source_v_s_prop = get_source_view_style(builder)
    props.merge!(source_v_s_prop)

    entry_props = get_entry_value(builder)
    props.merge!(entry_props)

    switch_props = get_switch_values(builder)
    props.merge!(switch_props)

    combo_props = get_combo_values(builder)
    props.merge!(combo_props)
  end

  def self.on_cancel_response(widget)
    puts "cancel"
    widget.destroy
  end

  def self.on_other_response(widget)
    widget.destroy
  end

  def self.add_actions(builder, parent)
    %w(audible_bell allow_bold scroll_on_output
       scroll_on_keystroke rewrap_on_resize mouse_autohide).each do |prop_name|
      gen_switch_actions(prop_name, builder, parent)
    end
    gen_entry_actions("shell", builder, parent)
    %w(cursor_shape cursor_blink_mode backspace_binding
       delete_binding).each do |prop_name|
      gen_combobox_actions(prop_name, builder, parent)
    end
    gen_spinbuttons_actions(builder, parent)
  end

  def self.gen_switch_actions(property_name, builder, parent)
    switch = builder["#{property_name}_switch"]
    switch.active = parent.notebook.current.send("#{property_name}?")
    switch.signal_connect "state-set" do |_widget, state|
      parent.notebook.send_to_all_terminals("#{property_name}=", state)
      false
    end
  end

  def self.gen_entry_actions(property_name, builder, parent)
    entry = builder["#{property_name}_entry"]
    entry.text = parent.shell
    entry.set_icon_from_icon_name(:secondary, "edit-clear")
    entry.signal_connect "activate" do |widget|
      parent.shell = widget.text
    end

    entry.signal_connect "icon-release" do |widget, position|
      if position == :secondary
        parent.shell = widget.text = parent.style_get_property(property_name)
      end
    end
  end

  def self.gen_combobox_actions(property_name, builder, parent)
    combobox = builder["#{property_name}_sel"]
    id = parent.notebook.current.send("#{property_name}").nick + "_id"
    combobox.active_id = id
    combobox.signal_connect "changed" do |widget|
      value = widget.active_id.gsub(/_id/, "").to_sym
      parent.notebook.send_to_all_terminals("#{property_name}=", value)
    end
  end

  def self.gen_spinbuttons_actions(builder, parent)
    width_spin = builder["width_spin"]
    height_spin = builder["height_spin"]
    width_spin.set_range(0, 2000)
    height_spin.set_range(0, 1000)
    width_spin.value, height_spin.value = parent.size

    width_spin.signal_connect "value-changed" do |widget|
      _, h = parent.size
      parent.resize(widget.value, h)
    end

    height_spin.signal_connect "value-changed" do |widget|
      w, _h = parent.size
      parent.resize(w, widget.value)
    end
  end

  # Hack because when added via glade, the builder fail to load the ui.
  def self.add_source_view_style_chooser(builder, parent)
    box = builder["gen_prefs_box"]
    button = GtkSource::StyleSchemeChooserButton.new
    sm = GtkSource::StyleSchemeManager.default
    button.style_scheme = sm.get_scheme(parent.css_editor_style)
    button.show
    button.signal_connect "style-updated" do |widget|
      parent.css_editor_style = widget.style_scheme.id
    end
    box.pack_start(button, :expand => true, :fill => false)
  end

  def self.get_source_view_style(builder)
    box = builder["gen_prefs_box"]
    penultimate = box.children.size - 2
    style = box.children[penultimate].style_scheme.id
    { "-TopinambourWindow-css-editor-style" =>  style }
  end

  def self.get_entry_value(builder)
    text = builder["shell_entry"].text
    { "-TopinambourWindow-shell" => text }
  end

  def self.get_switch_values(builder)
    props = {}
    %w(audible_bell allow_bold scroll_on_output
       scroll_on_keystroke rewrap_on_resize mouse_autohide).each do |prop_name|
      switch = builder["#{prop_name}_switch"]
      name = prop_name.tr("_", "-")
      props["-TopinambourTerminal-#{name}"] = switch.active?
    end
    props
  end

  def self.get_combo_values(builder)
    props = {}
    %w(cursor_shape cursor_blink_mode backspace_binding
       delete_binding).each do |prop_name|
      combobox = builder["#{prop_name}_sel"]
      value = combobox.active_id.gsub(/_id\z/, "")
      name = prop_name.tr("_", "-")
      props["-TopinambourTerminal-#{name}"] = value.to_sym
    end
    props
  end
end
