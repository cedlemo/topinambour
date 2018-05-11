# Copyright 2016-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

      %w(width_spin height_spin shell_entry audible_bell_switch
         allow_bold_switch scroll_on_output_switch scroll_on_keystroke_switch
         rewrap_on_resize_switch mouse_autohide_switch cursor_shape_sel
         cursor_blink_mode_sel backspace_binding_sel delete_binding_sel
         css_chooser_button use_custom_css_switch).each do |widget|
        bind_template_child(widget)
      end

      set_connect_func { |name| method(name) }
    end

    private

    def on_width_spin_value_changed_cb(spin)
      parent = spin.toplevel.transient_for
      height = parent.application.settings["height"]
      terminal = parent.terminal
      terminal.set_size(spin.value, height)
      parent.resize(*terminal.size)
    end

    def on_height_spin_value_changed_cb(spin)
      parent = spin.toplevel.transient_for
      width = parent.application.settings["width"]
      terminal = parent.terminal
      terminal.set_size(width, spin.value)
      parent.resize(*terminal.size)
    end

    def on_shell_entry_activate_cb(entry)
      style_context = entry.style_context

      if File.exist?(entry.text)
        settings = entry.toplevel.settings
        entry.set_icon_from_icon_name(:secondary, nil)
        style_context.remove_class("error")
        settings["default-shell"] = entry.text if settings
      else
        style_context.add_class("error")
        entry.set_icon_from_icon_name(:secondary, "dialog-warning-symbolic")
      end
    end

    def on_shell_entry_focus_out_event_cb(entry, _)
      style_context = entry.style_context

      if File.exist?(entry.text)
        settings = entry.toplevel.settings
        entry.set_icon_from_icon_name(:secondary, nil)
        style_context.remove_class("error")
        settings["default-shell"] = entry.text if settings
      else
        style_context.add_class("error")
        entry.set_icon_from_icon_name(:secondary, "dialog-warning-symbolic")
      end
    end

    def on_css_file_selected_cb(filechooser)
      parent = filechooser.toplevel.transient_for
      parent.application.settings["css-file"] = filechooser.filename
      parent.application.reload_css_config
    end

    def on_custom_css_switch_state_set(switch, _state)
      parent = switch.toplevel.transient_for
      setting = "custom-css"
      settings = parent.application.settings
      settings[setting] = switch.active?
      switch.toplevel.css_chooser_button.sensitive = settings[setting]
      parent.application.reload_css_config
      false
    end
  end

  attr_reader :settings
  def initialize(parent)
    super(:type => :toplevel)
    set_transient_for(parent)
    @parent = parent

    configure_headerbar

    signal_connect "delete-event" do |widget|
      widget.destroy
      @parent.terminal.grab_focus
    end

    @settings = @parent.application.settings

    initialize_widgets
  end

  private

  def initialize_widgets
    initialize_use_custom_css_settings
    bind_spin_buttons_with_settings
    bind_switches_with_settings
    bind_combo_boxes_with_settings

    shell_entry.text = @settings["default-shell"]

    css_chooser_button.current_folder = "#{ENV['HOME']}/.config/topinambour/"
    css_chooser_button.filename = @parent.application.check_css_file_path || ""
  end

  def bind_switches_with_settings
    bind_switch_state_with_setting(allow_bold_switch, "allow-bold")
    bind_switch_state_with_setting(audible_bell_switch, "audible-bell")
    bind_switch_state_with_setting(scroll_on_output_switch, "scroll-on-output")
    bind_switch_state_with_setting(scroll_on_keystroke_switch,
                                   "scroll-on-keystroke")
    bind_switch_state_with_setting(rewrap_on_resize_switch, "rewrap-on-resize")
    bind_switch_state_with_setting(mouse_autohide_switch, "mouse-autohide")
  end

  def bind_combo_boxes_with_settings
    bind_combo_box_with_setting(cursor_shape_sel, "cursor-shape")
    bind_combo_box_with_setting(cursor_blink_mode_sel, "cursor-blink-mode")
    bind_combo_box_with_setting(backspace_binding_sel, "backspace-binding")
    bind_combo_box_with_setting(delete_binding_sel, "delete-binding")
  end

  def bind_spin_buttons_with_settings
    bind_spin_button_with_setting(width_spin, "width")
    bind_spin_button_with_setting(height_spin, "height")
  end

  def configure_headerbar
    headerbar = Gtk::HeaderBar.new
    headerbar.title = "Topinambour Preferences"
    headerbar.show_close_button = true
    set_titlebar(headerbar)
  end

  def initialize_use_custom_css_settings
    setting = "custom-css"
    switch = use_custom_css_switch
    switch.active = @settings[setting]
    css_chooser_button.sensitive = @settings[setting]
  end

  def set_switch_to_initial_state(_switch, setting)
    state = @settings[setting]
    m = "#{setting.tr('-', '_')}="
    @parent.terminal.send(m, state)
  end

  def bind_switch_state_with_setting(switch, setting)
    set_switch_to_initial_state(switch, setting)
    @settings.bind(setting,
                   switch,
                   "active",
                   Gio::SettingsBindFlags::DEFAULT)
    switch.signal_connect "state-set" do |_switch, state|
      m = "#{setting.tr('-', '_')}="
      @parent.terminal.send(m, state)
      false
    end
  end

  def set_combo_to_initial_state(_combo_box, setting)
    active = @settings[setting]
    m = "#{setting.tr('-', '_')}="
    @parent.terminal.send(m, active)
  end

  def bind_combo_box_with_setting(combo_box, setting)
    set_combo_to_initial_state(combo_box, setting)
    @settings.bind(setting,
                   combo_box,
                   "active",
                   Gio::SettingsBindFlags::DEFAULT)
    combo_box.signal_connect "changed" do
      m = "#{setting.tr('-', '_')}="
      @parent.terminal.send(m, combo_box.active)
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
