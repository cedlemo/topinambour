# Copyright 2015-2016 Cédric LE MOIGNE, cedlemo@gmx.com
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

class TopinambourWindow
  attr_reader :notebook, :bar, :overlay, :current_label, :current_tab, :css_editor_style
  attr_accessor :shell
  def initialize(application)
    super(:application => application)
    set_icon_name("utilities-terminal-symbolic")
    load_css_properties
    set_position(:center)
    create_header_bar
    create_containers
    show_all
    signal_connect "key-press-event" do |widget, event|
      TopinambourShortcuts.handle_key_press(widget, event)
    end
  end

  def add_terminal(cmd = @shell)
    exit_overlay_mode
    working_dir = nil
    # Check if current tab is a TopinambourTerminal (can be TopinambourCssEditor)
    if @notebook.current.class == TopinambourTerminal && @notebook.n_pages > 0
      working_dir = @notebook.current.pid_dir
    end

    terminal = TopinambourTerminal.new(cmd, working_dir)
    terminal.show
    @notebook.append_page(terminal)
    @notebook.set_tab_reorderable(terminal, true)
    @notebook.set_page(@notebook.n_pages - 1)
    @notebook.current.grab_focus
  end

  def quit_gracefully
    exit_overlay_mode
    @notebook.remove_all_pages
    application.quit
  end

  def show_color_selector
    toggle_overlay(TopinambourColorSelector) if @notebook.current.class == TopinambourTerminal
  end

  def show_prev_tab
    exit_overlay_mode
    @notebook.cycle_prev_page
    @notebook.current.grab_focus
  end

  def show_next_tab
    exit_overlay_mode
    @notebook.cycle_next_page
    @notebook.current.grab_focus
  end

  def show_font_selector
    toggle_overlay(TopinambourFontSelector) if @notebook.current.class == TopinambourTerminal
  end

  def show_css_editor
    css_editor = TopinambourCssEditor.new(self)
    @notebook.append_page(css_editor, Gtk::Label.new)
    @notebook.set_page(@notebook.n_pages - 1)
  end

  def show_terminal_chooser
    toggle_overlay(TopinambourTermChooser)
  end

  def exit_overlay_mode
    @overlay.children[1].destroy if in_overlay_mode?
  end

  def load_css_properties
    @default_width = style_get_property("width")
    @default_height = style_get_property("height")
    set_default_size(@default_width, @default_height)
    set_size_request(@default_width, @default_height)
    @shell = style_get_property("shell")
    @css_editor_style = style_get_property("css-editor-style")
  end

  def display_about
    Gtk::AboutDialog.show(self,
                          "authors" => ["Cédric Le Moigne <cedlemo@gmx.com>"],
                          "comments" => "Terminal Emulator based on the ruby bindings of Gtk3 and Vte3",
                          "copyright" => "Copyright (C) 2015-2016 Cédric Le Moigne",
                          "license" => "This program is licenced under the licence GPL-3.0 and later.",
                          "logo_icon_name" => "utilities-terminal-symbolic",
                          "program_name" => "Topinambour",
                          "version" => "1.0.7",
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

  private

  def add_overlay(widget)
    @overlay.add_overlay(widget)
    @overlay.set_overlay_pass_through(widget, true)
  end

  def create_containers
    @notebook = TopinambourNotebook.new
    @overlay = Gtk::Overlay.new
    @overlay.add(@notebook)
    add(@overlay)
  end

  def create_header_bar
    @bar = TopinambourHeaderBar.generate_header_bar(self)
    @current_label = TopinambourHeaderBar.generate_current_label(self)
    @current_tab = TopinambourHeaderBar.generate_current_tab
    add_buttons_at_begining
    add_buttons_at_end
  end

  def add_buttons_at_begining
    button = TopinambourHeaderBar.generate_prev_button(self)
    @bar.pack_start(button)
    @bar.pack_start(@current_tab)
    button = TopinambourHeaderBar.generate_next_button(self)
    @bar.pack_start(button)
    @bar.pack_start(@current_label)
    button = TopinambourHeaderBar.generate_new_tab_button(self)
    @bar.pack_start(button)
  end

  def add_buttons_at_end
    button = TopinambourHeaderBar.generate_open_menu_button(self)
    @bar.pack_end(button)
    button = TopinambourHeaderBar.generate_font_sel_button(self)
    @bar.pack_end(button)
    button = TopinambourHeaderBar.generate_color_sel_button(self)
    @bar.pack_end(button)
    button = TopinambourHeaderBar.generate_term_overv_button(self)
    @bar.pack_end(button)
  end

  def toggle_overlay(klass)
    if in_overlay_mode? && @overlay.children[1].class == klass
      exit_overlay_mode
      @notebook.current.grab_focus
    else
      exit_overlay_mode
      add_overlay(klass.new(self))
      @overlay.children[1].show_all
    end
  end
end
