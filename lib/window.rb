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

class TopinambourWindow < Gtk::ApplicationWindow
  attr_reader :terminal, :overlay
  def initialize(application)
    super(application)
    set_icon_name("utilities-terminal-symbolic")
    set_name("topinambour-window")
    set_position(:center)
    @overlay = TopinambourOverlay.new
    create_header_bar
    signal_connect "key-press-event" do |widget, event|
    end
    add(@overlay)
  end

  def add_terminal(cmd = "/usr/bin/zsh")
    terminal = TopinambourTermBox.new(cmd, self)
    @overlay.add(terminal)
    @terminal = terminal.term
  end

  def create_header_bar
    headerbar = Gtk::HeaderBar.new
    headerbar.name = "topinambour-headerbar"
    headerbar.show_close_button = true
    set_titlebar(headerbar)
  end

end

class TopinambourOverlay < Gtk::Overlay

  # Add a widget over the main widget of the overlay.
  def add_overlay(widget)
    @overlay.add_overlay(widget)
    @overlay.set_overlay_pass_through(widget, false)
  end

  # Check if there is a widget displayed on top of the main widget.
  def in_overlay_mode?
    @overlay.children.size > 1
  end

  # Display only the main widget.
  def exit_overlay_mode
    @overlay.children[1].destroy if in_overlay_mode?
  end

  def toggle_overlay(klass)
    exit_overlay_mode
    if in_overlay_mode? && @overlay.children[1].class == klass
      @terminal.grab_focus
    else
      add_overlay(klass.new(self))
      @overlay.children[1].show_all
    end
  end

end
