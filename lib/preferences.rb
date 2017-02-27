# Copyright 2016-2017 Cedric LE MOIGNE, cedlemo@gmx.com
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

class TopinambourPreferences < Gtk::Window
  type_register
  class << self
    def init
      resource_file = "/com/github/cedlemo/topinambour/prefs-dialog.ui"
      set_template(:resource => resource_file)
      bind_template_child("width_spin")
      bind_template_child("height_spin")
      bind_template_child("shell_entry")
      bind_template_child("audible_bell_switch")
      bind_template_child("allow_bold_switch")
      bind_template_child("scroll_on_output_switch")
      bind_template_child("scroll_on_keystroke_switch")
      bind_template_child("rewrap_on_resize_switch")
      bind_template_child("mouse_autohide_switch")
      bind_template_child("cursor_shape_sel")
      bind_template_child("cursor_blink_mode_sel")
      bind_template_child("backspace_binding_sel")
      bind_template_child("delete_binding_sel")

      set_connect_func do |name|
        method(name)
      end

      private

      def on_width_spin_value_changed(spin)
        parent = spin.toplevel.transient_for
        height = parent.application.settings["height"]
        parent.resize(spin.value, height)
      end

      def on_height_spin_value_changed(spin)
        parent = spin.toplevel.transient_for
        width = parent.application.settings["width"]
        parent.resize(width, spin.value)
      end

      def on_shell_entry_activate(entry)
        style_context = entry.style_context

        if File.exists?(entry.text)
          settings = entry.toplevel.settings
          entry.set_icon_from_icon_name(:secondary, nil)
          style_context.remove_class("error")
          settings["default-shell"] = entry.text if settings
        else
          style_context.add_class("error")
          entry.set_icon_from_icon_name(:secondary, "dialog-warning-symbolic")
        end
      end

      def on_shell_entry_focus_out_event(entry, nope)
        style_context = entry.style_context

        if File.exists?(entry.text)
          settings = entry.toplevel.settings
          entry.set_icon_from_icon_name(:secondary, nil)
          style_context.remove_class("error")
          settings["default-shell"] = entry.text if settings
        else
          style_context.add_class("error")
          entry.set_icon_from_icon_name(:secondary, "dialog-warning-symbolic")
        end
      end
    end
  end

  attr_reader :settings
  def initialize(parent)
    super(:type => :toplevel)
    set_transient_for(parent)
    headerbar = Gtk::HeaderBar.new
    headerbar.title = "Topinambour Preferences"
    headerbar.show_close_button = true
    set_titlebar(headerbar)
    @parent = parent
    signal_connect "delete-event" do |widget|
      widget.destroy
      @parent.notebook.current.term.grab_focus
    end

    @settings = @parent.application.settings

    bind_spin_button_with_setting(width_spin, "width")
    bind_spin_button_with_setting(height_spin, "height")

    bind_switch_state_with_setting(allow_bold_switch, "allow-bold")
    bind_switch_state_with_setting(audible_bell_switch, "audible-bell")
    bind_switch_state_with_setting(scroll_on_output_switch, "scroll-on-output")
    bind_switch_state_with_setting(scroll_on_keystroke_switch, "scroll-on-keystroke")
    bind_switch_state_with_setting(rewrap_on_resize_switch, "rewrap-on-resize")
    bind_switch_state_with_setting(mouse_autohide_switch, "mouse-autohide")

    bind_combo_box_with_setting(cursor_shape_sel, "cursor-shape")
    bind_combo_box_with_setting(cursor_blink_mode_sel, "cursor-blink-mode")
    bind_combo_box_with_setting(backspace_binding_sel, "backspace-binding")
    bind_combo_box_with_setting(delete_binding_sel, "delete-binding")

    shell_entry.text = @settings["default-shell"]
  end

  private

  def set_switch_to_initial_state(switch, setting)
    state = @settings[setting]
    m = "#{setting.gsub(/-/,"_")}="
    @parent.notebook.each do |tab|
      tab.term.send(m, state)
    end
  end

  def bind_switch_state_with_setting(switch, setting)
    set_switch_to_initial_state(switch, setting)
    @settings.bind(setting,
                  switch,
                  "active",
                  Gio::SettingsBindFlags::DEFAULT)
    switch.signal_connect "state-set" do |switch, state|
      m = "#{setting.gsub(/-/,"_")}="
      @parent.notebook.each do |tab|
        tab.term.send(m, state)
      end
      false
    end
  end

  def set_combo_to_initial_state(combo_box, setting)
    active = @settings[setting]
    m = "#{setting.gsub(/-/,"_")}="
    @parent.notebook.each do |tab|
      tab.term.send(m, active)
    end
  end

  def bind_combo_box_with_setting(combo_box, setting)
    set_combo_to_initial_state(combo_box, setting)
    @settings.bind(setting,
                   combo_box,
                   "active",
                   Gio::SettingsBindFlags::DEFAULT)
    combo_box.signal_connect "changed" do
      index = combo_box.active
      m = "#{setting.gsub(/-/,"_")}="
      @parent.notebook.each do |tab|
        tab.term.send(m, index)
      end
      false
    end
  end

  def bind_spin_button_with_setting(spin_button, setting)
    @settings.bind(setting,
                   spin_button,
                   "value",
                   Gio::SettingsBindFlags::DEFAULT)
  end
end
