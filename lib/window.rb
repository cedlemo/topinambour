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
  attr_reader :bar, :overlay, :terminal
  def initialize(application)
    super(application)
    set_icon_name("utilities-terminal-symbolic")
    set_name("topinambour-window")
    load_settings
    set_position(:center)
    create_header_bar
    @overlay = Gtk::Overlay.new
    add(@overlay)
    show_all
    signal_connect "key-press-event" do |widget, event|
      TopinambourShortcuts.handle_key_press(widget, event)
    end
  end

  def add_terminal(cmd = nil)
    cmd = cmd || application.settings["default-shell"]

    terminal = TopinambourTermBox.new(cmd)
    @overlay.add(terminal)
    @terminal = terminal.term
    terminal.term.load_settings
  end

  def quit_gracefully
    application.quit
  end

  def show_color_selector
    toggle_overlay(TopinambourColorSelector)
  end

  def show_font_selector
    toggle_overlay(TopinambourFontSelector)
  end

  def exit_overlay_mode
    @overlay.children[1].destroy if in_overlay_mode?
  end

  def display_about
    Gtk::AboutDialog.show(self,
                          "authors" => ["Cedric Le Moigne <cedlemo@gmx.com>"],
                          "comments" => "Terminal Emulator based on the ruby bindings of Gtk3 and Vte3",
                          "copyright" => "Copyright (C) 2015-2018 Cedric Le Moigne",
                          "license" => "This program is licenced under the licence GPL-3.0 and later.",
                          "logo_icon_name" => "utilities-terminal-symbolic",
                          "program_name" => "Topinambour",
                          "version" => "2.0.4",
                          "website" => "https://github.com/cedlemo/topinambour",
                          "website_label" => "Topinambour github repository"
                         )
  end

  def in_overlay_mode?
    @overlay.children.size > 1 ? true : false
  end

  def toggle_shrink
    w, h = size
    if @shrink_saved_height
      resize(w, @shrink_saved_height)
      @shrink_saved_height = nil
    else
      resize(w, 1)
      @shrink_saved_height = h
    end
  end

  def show_shortcuts
    resource_file = "/com/github/cedlemo/topinambour/shortcuts.ui"
    builder = Gtk::Builder.new(:resource => resource_file)
    shortcuts_win = builder["shortcuts-window"]
    shortcuts_win.transient_for = self
    shortcuts_win.show
  end
  private

  def load_settings
    height = application.settings["height"]
    width = application.settings["width"]
    resize(width, height)
  end

  def add_overlay(widget)
    @overlay.add_overlay(widget)
    @overlay.set_overlay_pass_through(widget, false)
  end

  def create_header_bar
    headerbar = Gtk::HeaderBar.new
    headerbar.name = "topinambour-headerbar"
    headerbar.show_close_button = true
    set_titlebar(headerbar)
  end

  def main_menu_signal(builder)
    button = builder["menu_button"]
    ui_file = "/com/github/cedlemo/topinambour/main-menu-popover.ui"
    menu_builder = Gtk::Builder.new(:resource => ui_file)
    main_menu = menu_builder["main_menu_popover"]
    button.set_popover(main_menu)
    button.popover.modal = true
    add_theme_menu_buttons_signals(menu_builder)
  end

  def add_theme_menu_buttons_signals(builder)
    builder["css_reload_button"].signal_connect "clicked" do
      application.reload_css_config
      queue_draw
    end

    builder["font_sel_button"].signal_connect "clicked" do
      show_font_selector
    end

    builder["colors_sel_button"].signal_connect "clicked" do
      show_color_selector
    end
  end

  def toggle_overlay(klass)
    if in_overlay_mode? && @overlay.children[1].class == klass
      exit_overlay_mode
      @terminal.grab_focus
    else
      exit_overlay_mode
      add_overlay(klass.new(self))
      @overlay.children[1].show_all
    end
  end
end
