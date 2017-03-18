# Copyright 2015-2017 Cedric LE MOIGNE, cedlemo@gmx.com
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
  attr_reader :notebook, :bar, :overlay, :current_label, :current_tab
  def initialize(application)
    super(application)
    set_icon_name("utilities-terminal-symbolic")
    set_name("topinambour-window")
    load_settings
    set_position(:center)
    create_header_bar
    create_containers
    show_all
    signal_connect "key-press-event" do |widget, event|
      TopinambourShortcuts.handle_key_press(widget, event)
    end
    signal_connect "scroll-event" do |widget, event|
      TopinambourShortcuts.handle_scroll(widget, event)
    end
  end

  def add_terminal
    shell = application.settings["default-shell"]
    exit_overlay_mode
    working_dir = nil
    working_dir = @notebook.current.term.pid_dir if @notebook.current

    terminal = TopinambourTabTerm.new(shell, working_dir)
    terminal.show_all

    @notebook.append_page(terminal)
    terminal.term.load_settings
    @notebook.set_tab_reorderable(terminal, true)
    @notebook.set_page(@notebook.n_pages - 1)
    @notebook.current.term.grab_focus

  end

  def quit_gracefully
    exit_overlay_mode
    @notebook.remove_all_pages
    application.quit
  end

  def show_color_selector
    toggle_overlay(TopinambourColorSelector)
  end

  def show_prev_tab
    exit_overlay_mode
    @notebook.cycle_prev_page
    @notebook.current.term.grab_focus
  end

  def show_next_tab
    exit_overlay_mode
    @notebook.cycle_next_page
    @notebook.current.term.grab_focus
  end

  def show_font_selector
    toggle_overlay(TopinambourFontSelector)
  end

  def show_terminal_chooser
    toggle_overlay(TopinambourTermChooser)
  end

  def exit_overlay_mode
    @overlay.children[1].destroy if in_overlay_mode?
  end

  def display_about
    Gtk::AboutDialog.show(self,
                          "authors" => ["Cedric Le Moigne <cedlemo@gmx.com>"],
                          "comments" => "Terminal Emulator based on the ruby bindings of Gtk3 and Vte3",
                          "copyright" => "Copyright (C) 2015-2016 Cedric Le Moigne",
                          "license" => "This program is licenced under the licence GPL-3.0 and later.",
                          "logo_icon_name" => "utilities-terminal-symbolic",
                          "program_name" => "Topinambour",
                          "version" => "1.0.12",
                          "website" => "https://github.com/cedlemo/topinambour",
                          "website_label" => "Topinambour github repository"
                         )
  end

  def close_current_tab
    exit_overlay_mode
    @notebook.remove_current_page
  end

  def in_overlay_mode?
    @overlay.children.size > 1 ? true : false
  end

  def show_searchbar
    toggle_overlay(TopinambourSearchBar)
    overlayed_widget = @overlay.children[1]
    overlayed_widget.search_mode = true if overlayed_widget
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

  def create_containers
    @notebook = TopinambourNotebook.new
    @overlay = Gtk::Overlay.new
    @overlay.add(@notebook)
    add(@overlay)
  end

  def create_header_bar
    resource_file = "/com/github/cedlemo/topinambour/headerbar.ui"
    builder = Gtk::Builder.new(:resource => resource_file)
    headerbar = builder["headerbar"]
    headerbar.name = "topinambour-headerbar"
    set_titlebar(headerbar)
    # Text is modified when notebook switch tabs or
    # Vte::Terminal command change and if it is the current Vte.
    @current_label = builder["current_label"]
    current_label_signals
    # Value is changed when notebook switch tabs or notebook add tab.
    @current_tab = builder["current_tab"]
    next_prev_new_signals(builder)
    overview_signal(builder)
    main_menu_signal(builder)
    theme_menu_signal(builder)
  end

  def current_label_signals
    @current_label.signal_connect "activate" do |entry|
      @notebook.current.term.custom_title = entry.text
      @notebook.current.term.grab_focus
    end

    @current_label.signal_connect "icon-release" do |entry, position|
      if position == :secondary
        @notebook.current.term.custom_title = nil
        entry.text = @notebook.current.term.window_title
      end
    end
  end

  def next_prev_new_signals(builder)
    builder["prev_button"].signal_connect "clicked" do
      show_prev_tab
    end

    builder["next_button"].signal_connect "clicked" do
      show_next_tab
    end

    builder["new_term"].signal_connect "clicked" do
      add_terminal
    end
  end

  def overview_signal(builder)
    builder["term_overv_button"].signal_connect "clicked" do
      show_terminal_chooser
    end
  end

  def main_menu_signal(builder)
    builder["menu_button"].signal_connect "clicked" do |button|
      ui_file = "/com/github/cedlemo/topinambour/window-menu.ui"
      winmenu = Gtk::Builder.new(:resource => ui_file)["winmenu"]
      event = Gtk.current_event
      menu = Gtk::Popover.new(button, winmenu)
      x, y = event.window.coords_to_parent(event.x,
                                         event.y)
      rect = Gdk::Rectangle.new(x - button.allocation.x,
                                y - button.allocation.y,
                                1, 1)
      menu.set_pointing_to(rect)
      menu.show
    end
  end

  def theme_menu_signal(builder)
    builder["theme_button"].signal_connect "clicked" do |button|
      unless @theme_menu
        ui_file = "/com/github/cedlemo/topinambour/theme-popover.ui"
        b = Gtk::Builder.new(:resource => ui_file)
        @theme_menu = b["theme_popover"]
        add_theme_menu_buttons_signals(b)
      end

      if @theme_menu.mapped?
        @theme_menu.popdown
      else
        @theme_menu.relative_to = button
        event = Gtk.current_event
        x, y = event.window.coords_to_parent(event.x,
                                           event.y)
        rect = Gdk::Rectangle.new(x - button.allocation.x,
                                  y - button.allocation.y,
                                  1, 1)
        @theme_menu.set_pointing_to(rect)
        @theme_menu.popup
      end
    end
  end

  def add_theme_menu_buttons_signals(builder)
    builder["css_reload_button"].signal_connect "clicked" do
      @theme_menu.popdown
      application.reload_css_config
      queue_draw
    end

    builder["font_sel_button"].signal_connect "clicked" do
      @theme_menu.popdown
      show_font_selector
    end

    builder["colors_sel_button"].signal_connect "clicked" do
      @theme_menu.popdown
      show_color_selector
    end
  end

  def toggle_overlay(klass)
    if in_overlay_mode? && @overlay.children[1].class == klass
      exit_overlay_mode
      @notebook.current.term.grab_focus
    else
      exit_overlay_mode
      add_overlay(klass.new(self))
      @overlay.children[1].show_all
    end
  end
end
