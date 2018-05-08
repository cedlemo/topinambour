# Copyright 2016-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

# Those are all the actions that can be called via the interface with
# the label 'app.my_action' for a method my_action.
module TopinambourActions
  def self.generate_action(name)
    action = Gio::SimpleAction.new(name)
    action.signal_connect("activate") do |act, param|
      yield(act, param) if block_given?
    end
    action
  end

  def self.add_action_to(name, application)
    method_name = "generate_#{name}_action".to_sym
    return false unless methods.include?(method_name)
    action = method(method_name).call(application)
    application.add_action(action)
  end

  def self.generate_about_action(application)
    action = generate_action("about") do |_act, _param|
      application.windows[0].display_about
    end
    action
  end
#
#  def self.generate_preferences_action(application)
#    action = generate_action("preferences") do |_act, _param|
#      dialog = TopinambourPreferences.new(application.windows.first)
#      dialog.show_all
#    end
#    action
#  end

  def self.generate_quit_action(application)
    action = generate_action("quit") do |_act, _param|
      application.quit
    end
    action
  end

  def self.generate_term_copy_action(application)
    action = generate_action("term_copy") do |_act, _param|
      term = application.windows[0].terminal
      event = Gtk.current_event

      _match, regex_type = term.match_check_event(event)
      if term.has_selection? || regex_type == -1
        term.copy_clipboard
      else
        clipboard = Gtk::Clipboard.get_default(Gdk::Display.default)
        clipboard.text = term.last_match unless term.last_match.nil?
      end
    end
    action
  end

  def self.generate_term_paste_action(application)
    action = generate_action("term_paste") do |_act, _param|
      application.windows[0].terminal.paste_clipboard
    end
    action
  end

  def self.generate_shortcuts_action(application)
    action = generate_action("shortcuts") do |_act, _param|
      application.windows[0].show_shortcuts
    end
    action
  end

  def self.add_actions_to(application)
    # preferences
    # %w(about quit term_copy term_paste preferences shortcuts).each do |name|
    %w(quit term_copy term_paste shortcuts).each do |name|
      add_action_to(name, application)
    end
  end
end
