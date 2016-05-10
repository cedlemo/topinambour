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
    builder = Gtk::Builder.new(:resource => "/com/github/cedlemo/topinambour/prefs-dialog.ui")
    dialog = builder["Preferences_dialog"]
    dialog.transient_for = parent
    add_source_view_style_chooser(builder, parent)
    add_actions(builder, parent)
    connect_response(dialog)
    dialog
  end

  def self.connect_response(dialog)
    dialog.signal_connect "response" do |widget, response|
      case response
      when Gtk::ResponseType::OK
        on_ok_response(widget)
      when Gtk::ResponseType::APPLY
        on_apply_response(widget)
      when Gtk::ResponseType::CANCEL
        on_cancel_response(widget)
      else
        on_other_response(widget)
      end
    end
  end

  def self.on_ok_response(widget)
    puts "accept"
    widget.destroy
  end

  def self.on_apply_response(widget)
    puts "apply"
    widget.destroy
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
    %w(cursor_shape cursor_blink_mode backspace_binding delete_binding).each do |prop_name|
      gen_combobox_actions(prop_name, builder, parent)
    end
  end

  def self.gen_switch_actions(property_name, builder, parent)
    switch = builder["#{property_name}_switch"]
    switch.active = parent.notebook.current.send("#{property_name}?")
    switch.signal_connect "state-set" do |_widget, state|
      send_to_all_terminals(parent.notebook, "#{property_name}=", state)
      false
    end
  end

  def self.send_to_all_terminals(notebook, method_name, values)
    notebook.each do |tab|
      next unless tab.class == TopinambourTerminal
      tab.send(method_name, *values)
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
      value = widget.active_id.gsub(/_id/,"").to_sym
      send_to_all_terminals(parent.notebook, "#{property_name}=", value)
    end
  end
  
  # Hack because when added via glade, the builder fail to load the ui.
  def self.add_source_view_style_chooser(builder, parent)
    box = builder["gen_prefs_box"]
    button = GtkSource::StyleSchemeChooserButton.new
    sm = GtkSource::StyleSchemeManager.default
    puts parent.css_editor_style
    button.style_scheme = sm.get_scheme(parent.css_editor_style)
    button.show
    button.signal_connect "style-updated" do |widget|
      parent.css_editor_style = widget.style_scheme.id
    end
    box.pack_start(button, :expand => true, :fill => false)
  end
end
