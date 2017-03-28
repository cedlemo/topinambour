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

module TopinambourShortcuts
  def self.ctrl_shift?(event)
    (event.state & (Gdk::ModifierType::CONTROL_MASK |
                    Gdk::ModifierType::SHIFT_MASK)) ==
      (Gdk::ModifierType::CONTROL_MASK | Gdk::ModifierType::SHIFT_MASK)
  end

  def self.handle_simple(event, window)
    overlay_mode = window.in_overlay_mode?
    case event.keyval
    when Gdk::Keyval::KEY_Escape # escape from overlay mode
      if window.in_overlay_mode?
        window.exit_overlay_mode
        window.notebook.current.term.grab_focus
        true
      end
    end
  end

  def self.handle_ctrl_shift(event, window)
    case event.keyval
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
    when Gdk::Keyval::KEY_O
      window.show_terminal_chooser
      true
    when Gdk::Keyval::KEY_slash
      window.show_searchbar
      true
    when Gdk::Keyval::KEY_Page_Up
      window.opacity = window.opacity + 0.05
      true
    when Gdk::Keyval::KEY_Page_Down
      window.opacity = window.opacity - 0.05
      true
    end
  end

  def self.handle_key_press(window, event)
    keyval = event.keyval
    if ctrl_shift?(event)
      handle_ctrl_shift(event, window)
    else
      handle_simple(event, window)
    end
  end
end
