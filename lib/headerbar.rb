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

module TopinambourHeaderBar
  def self.generate_header_bar(window)
    bar = Gtk::HeaderBar.new
    bar.title = "Topinambour"
    bar.has_subtitle = false
    bar.show_close_button = true
    window.set_titlebar(bar)
    bar
  end

  def self.generate_current_label_tooltips(label)
    label.tooltip_text = <<-TOOLTIP
Change the name of the tab and hit
enter in order to validate
TOOLTIP
    label.set_icon_tooltip_text(:secondary, <<-SECTOOLTIP)
Reset your changes and use the
default label for the current tab
SECTOOLTIP
  end

  def self.generate_current_label_signals(label, window)
    label.signal_connect "activate" do |entry|
      window.notebook.current.tab_label = entry.text
    end

    label.signal_connect "icon-release" do |entry, position|
      if position == :secondary
        window.notebook.current.tab_label = nil
        entry.text = window.notebook.current.window_title
      end
    end
  end

  def self.generate_current_label(window)
    label = Gtk::Entry.new
    label.has_frame = false
    label.width_chars = 35
    label.set_icon_from_icon_name(:secondary, "edit-clear")

    generate_current_label_tooltips(label)
    generate_current_label_signals(label, window)
    label
  end

  def self.generate_prev_button(window)
    gen_icon_button("pan-start-symbolic", "prev") do
      window.show_prev_tab
    end
  end

  def self.generate_current_tab
    Gtk::Label.new("1/1")
  end

  def self.generate_next_button(window)
    gen_icon_button("pan-end-symbolic", "next") do
      window.show_next_tab
    end
  end

  def self.generate_new_tab_button(window)
    gen_icon_button("tab-new-symbolic", "New terminal") do
      window.add_terminal
    end
  end

  def self.generate_open_menu_button(window)
    gen_icon_button("open-menu-symbolic", "Main Menu") do |button|
      builder = Gtk::Builder.new(:resource => "/com/github/cedlemo/germinal/window-menu.ui")
      menu = Gtk::Menu.new(builder["winmenu"])
      menu.attach_to_widget(button)
      menu.children[0].signal_connect("activate") { window.show_css_editor }

      menu.show_all
      event = Gtk.current_event
      menu.popup(nil, nil, event.button, event.time)
    end
  end

  def self.generate_font_sel_button(window)
    gen_icon_button("font-select-symbolic", "Set font") do
      window.show_font_selector
    end
  end

  def self.generate_color_sel_button(window)
    gen_icon_button("color-select-symbolic", "Set colors") do
      window.show_color_selector
    end
  end

  def self.generate_term_overv_button(window)
    gen_icon_button("emblem-photos-symbolic", "Terminals overview") do
      window.show_terminal_chooser
    end
  end

  def self.gen_icon_button(icon_name, tooltip)
    button = Gtk::Button.new
    image = Gtk::Image.new(:icon_name => icon_name, :size => :button)
    button.add(image)
    button.tooltip_text = tooltip
    if block_given?
      button.signal_connect "clicked" do |widget|
        yield(widget)
      end
    end
    button
  end
end
