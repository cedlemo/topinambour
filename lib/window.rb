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
  attr_reader :bar, :terminal
  def initialize(application)
    super(application)
    set_icon_name("utilities-terminal-symbolic")
    set_name("topinambour-window")
    set_position(:center)
    create_header_bar
    signal_connect "key-press-event" do |widget, event|
    end
  end

  def add_terminal(cmd = "/usr/bin/zsh")
    terminal = TopinambourTermBox.new(cmd)
    add(terminal)
    @terminal = terminal.term
  end

  def create_header_bar
    headerbar = Gtk::HeaderBar.new
    headerbar.name = "topinambour-headerbar"
    headerbar.show_close_button = true
    set_titlebar(headerbar)
  end
end
