# Copyright 2016 Cedric LE MOIGNE, cedlemo@gmx.com
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

class TopinambourSearchBar < Gtk::SearchBar
  def initialize(window)
    super()

    generate_search_entry(window)
    set_halign(:center)
    set_valign(:start)
    set_hexpand(false)
    set_vexpand(true)
    connect_entry(@entry)
    set_show_close_button = true
    add(@entry)
  end

  def generate_search_entry(window)
    @entry = Gtk::SearchEntry.new
    term = window.notebook.current
    @entry.signal_connect "next-match" do |entry|
      puts "next-match"
      term.search_find_next if @regex
    end

    @entry.signal_connect "previous-match" do |entry|
      puts "prev match"
      term.search_find_previous if @regex
    end

    @entry.signal_connect "search-changed" do |entry|
      puts "search changed"
      pattern = entry.buffer.text
      if pattern != ""
        @regex = GLib::Regex.new(pattern)
        term.search_set_gregex(@regex, @regex.match_flags)
        term.search_find_next
      end
    end
  end
end
