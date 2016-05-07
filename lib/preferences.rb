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
require "gtksourceview3"

module TopinambourPreferences
  def self.generate_dialog(parent)
    builder = Gtk::Builder.new(:resource => "/com/github/cedlemo/topinambour/prefs-dialog.ui")
    dialog = builder["Preferences_dialog"]
    #dialog.set_default_size(800, 400)
    dialog.transient_for = parent
    dialog.signal_connect "response" do |widget, response|
      case response 
      when Gtk::ResponseType::OK
        on_ok_response(widget)
      when Gtk::ResponseType::APPLY
        on_apply_response(widget)
      when Gtk::ResponseType::CANCEL
        on_cancel_response(widget)
      else
        on_other_response(widget)
      end
    end
    dialog
  end

  def self.on_ok_response(widget)
    puts "accept"
    widget.destroy
  end

  def self.on_apply_response(widget)
    puts "apply"
    widget.destroy
  end

  def self.on_cancel_response(widget)
    puts "cancel"
    widget.destroy
  end
  
  def self.on_other_response(widget)
    widget.destroy
  end
end
