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

require "#{__dir__}/version"
## About stores metainformation about Topinambour.
module About
  AUTHORS = ["Cedric Le Moigne <cedlemo@gmx.com>"].freeze
  SUMMARY = "Vte3 Terminal emulator in ruby.".freeze
  COMMENTS =
    "Terminal Emulator based on the ruby bindings of Gtk3 and Vte3".freeze
  COPYRIGHT = "Copyright (C) 2015-2018 Cedric Le Moigne".freeze
  LICENSE = "GPL-3.0".freeze
  LICENSE_COMMENTS =
    "This program is licenced under the licence GPL-3.0 and later.".freeze
  LOGO_ICON_NAME = "utilities-terminal-symbolic".freeze
  PROGRAM_NAME = "Topinambour".freeze
  VERSION = Version::STRING
  WEBSITE = "https://github.com/cedlemo/topinambour".freeze
  WEBSITE_LABEL = "Topinambour github repository".freeze

  def self.dialog(parent)
    Gtk::AboutDialog.show(parent,
                          "authors" => AUTHORS,
                          "comments" => COMMENTS,
                          "copyright" => COPYRIGHT,
                          "license" => LICENSE,
                          "logo_icon_name" => LOGO_ICON_NAME,
                          "program_name" => PROGRAM_NAME,
                          "version" => VERSION,
                          "website" => WEBSITE,
                          "website_label" => WEBSITE_LABEL)
  end
end
