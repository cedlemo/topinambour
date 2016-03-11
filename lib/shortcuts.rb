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

module TopinambourShortcuts
  def self.ctrl_shift?(event)
    (event.state & (Gdk::ModifierType::CONTROL_MASK |
                    Gdk::ModifierType::SHIFT_MASK)) ==
      (Gdk::ModifierType::CONTROL_MASK | Gdk::ModifierType::SHIFT_MASK)
  end

  def self.handle_simple(keyval, window)
    case keyval
    when Gdk::Keyval::KEY_Escape # escape from overlay mode
      if window.in_overlay_mode?
        window.exit_overlay_mode
        window.notebook.current.grab_focus
        true
      end
    end
  end

  def self.handle_ctrl_shift(keyval, window)
    case keyval
    when Gdk::Keyval::KEY_W # close the current tab
      window.close_current_tab
      true
    when Gdk::Keyval::KEY_Q # Quit
      window.quit_gracefully
      true
    when Gdk::Keyval::KEY_T # New tab
      window.add_terminal
      true
    when Gdk::Keyval::KEY_C
      window.show_color_selector
      true
    when Gdk::Keyval::KEY_F
      window.show_font_selector
      true
    when Gdk::Keyval::KEY_Left # previous tab
      window.show_prev_tab
      true
    when Gdk::Keyval::KEY_Right # next tab
      window.show_next_tab
      true
    when Gdk::Keyval::KEY_O # next tab
      window.show_terminal_chooser
      true
    when Gdk::Keyval::KEY_E
      window.show_css_editor
      true
    end
  end

  def self.handle_key_press(window, event)
    keyval = event.keyval
    #puts "#{Gdk::Keyval.to_name(keyval)} = #{keyval}"
    if ctrl_shift?(event)
      handle_ctrl_shift(keyval, window)
    else
      handle_simple(keyval, window)
    end
  end
end
