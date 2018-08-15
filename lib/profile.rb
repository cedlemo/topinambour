# Copyright 2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

##
# Session or Profile class
# Allow to switch easily between different configurations.
class Profile
  attr_accessor :name,
                :terminal_options,
                :vte_options
  def initialize(terminal_options, vte_options)
    @terminal_options = terminal_options
    @vte_options = vte_options
  end

  ## TODO : use json
  def save
    # File.open("#{DATA_HOME_DIR}/#{@name}", 'w+') do |f|
    #   Marshal.dump(self, f)
    # end
  end

  def load
    # File.open("#{DATA_HOME_DIR}/#{@name}") do |f|
    #   session = Marshal.load(f)
    #   @terminal_options = session.terminal_options
    #   @vte_options = session.vte_options
    # end
  end
end

TerminalOptions = Struct.new(:colorscheme,
                             :default_scheme,
                             :font,
                             :width,
                             :height,
                             :custom_css,
                             :css_file)

VteOptions = Struct.new(:allow_bold,
                        :audible_bell,
                        :scroll_on_output,
                        :scroll_on_keystroke,
                        :rewrap_on_resize,
                        :mouse_autohide,
                        :cursor_shape,
                        :cursor_blink_mode,
                        :backspace_binding,
                        :delete_binding)
