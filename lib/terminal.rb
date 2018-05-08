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

## The main full tab Gtk::Box + Vte::Terminal + Gtk::Scrollbar
#

class TopinambourTermBox < Gtk::Box
  attr_reader :term
  def initialize(command_string, working_dir = nil)
    super(:horizontal, 0)
    set_name("topinambour-term-box")
    @term = TopinambourTerminal.new(command_string, working_dir)
    @scrollbar = Gtk::Scrollbar.new(:vertical, @term.vadjustment)
    @scrollbar.name = "topinambour-scrollbar"
    @term.show
    @scrollbar.show
    pack_start(@term, :expand => true, :fill => true, :padding => 0)
    pack_start(@scrollbar)
    show_all
  end
end

##
# The default vte terminal customized
class TopinambourTerminal < Vte::Terminal
  attr_reader :pid, :menu
  ##
  # Create a new TopinambourTerminal instance that runs command_string
  def initialize(command_string, working_dir = nil)
    super()
    set_name("topinambour-terminal")
    command_array = parse_command(command_string)
    rescued_spawn(command_array, working_dir)

    signal_connect "child-exited" do |widget|
    end
    set_size(180, 20)
  end

  def pid_dir
    File.readlink("/proc/#{@pid}/cwd")
  end

  def terminal_title
    @custom_title.class == String ? @custom_title : window_title.to_s
  end

  private

  def parse_command(command_string)
    GLib::Shell.parse(command_string)
  rescue GLib::ShellError => e
    STDERR.puts "domain  = #{e.domain}"
    STDERR.puts "code    = #{e.code}"
    STDERR.puts "message = #{e.message}"
  end

  def rescued_spawn(command_array, working_dir)
    @pid = spawn(:argv => command_array,
                 :working_directory => working_dir,
                 :spawn_flags => GLib::Spawn::SEARCH_PATH)
  rescue => e
    STDERR.puts e.message
  end
end
