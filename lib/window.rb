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

## Actions of the window that will be called throught the Application instance.
#  or throught terminal signals.
module TopinambourWindowActions
  def quit_gracefully
    application.quit
  end

  def show_color_selector
    @overlay.toggle_overlay(TopinambourColorSelector)
  end

  def show_font_selector
    @overlay.toggle_overlay(TopinambourFontSelector)
  end

  def display_about
    About.dialog(self)
  end

  def show_shortcuts
    resource_file = "/com/github/cedlemo/topinambour/shortcuts.ui"
    builder = Gtk::Builder.new(:resource => resource_file)
    shortcuts_win = builder["shortcuts-window"]
    shortcuts_win.transient_for = self
    shortcuts_win.show
  end
end

## Main window of Topinambour
#
class TopinambourWindow < Gtk::ApplicationWindow
  attr_reader :terminal, :overlay
  include TopinambourWindowActions

  def initialize(application)
    super(application)
    set_icon_name("utilities-terminal-symbolic")
    set_name("topinambour-window")
    set_position(:center)
    @overlay = TopinambourOverlay.new
    create_header_bar

    signal_connect "key-press-event" do |widget, event|
      TopinambourShortcuts.handle_key_press(widget, event)
    end

    add(@overlay)
  end

  def add_terminal(cmd = "/usr/bin/zsh")
    terminal = TopinambourTermBox.new(cmd, self)
    @terminal = terminal.term
    @overlay.add_main_widget(terminal)
  end

  def create_header_bar
    headerbar = Gtk::HeaderBar.new
    headerbar.name = "topinambour-headerbar"
    headerbar.show_close_button = true
    set_titlebar(headerbar)
  end
end

## This overlay contains the main terminal and allows another widgets to be
#  displayed on top of it.
class TopinambourOverlay < Gtk::Overlay
  def initialize
    super()
  end

  def add_main_widget(terminal)
    @terminal = terminal
    add(@terminal)
  end

  # Add a widget over the main widget of the overlay.
  def add_secondary_widget(widget)
    add_overlay(widget)
    set_overlay_pass_through(widget, false)
  end

  # Check if there is a widget displayed on top of the main widget.
  def in_overlay_mode?
    children.size > 1
  end

  # Display only the main widget.
  def exit_overlay_mode
    children[1].destroy if in_overlay_mode?
  end

  def toggle_overlay(klass)
    exit_overlay_mode
    if in_overlay_mode? && @overlay.children[1].class == klass
      @terminal.term.grab_focus
    else
      add_secondary_widget(klass.new(@terminal.toplevel))
      children[1].show_all
    end
  end
end
