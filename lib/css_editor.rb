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
require "gtksourceview3"
class TopinambourCssEditor < Gtk::Grid
  attr_accessor :tab_label, :preview
  def initialize(window)
    super()
    @window = window
    @provider = window.application.provider
    @default_css = @provider.to_s
    @modified_css = @default_css
    @tab_label = "Css Editor"

    gen_source_view

    sw = Gtk::ScrolledWindow.new(nil, nil)
    sw.vexpand = true
    sw.hexpand = true
    sw.add(@view)
    attach(sw, 0, 0, 3, 1)

    button = gen_reset_button
    attach(button, 0, 1, 1, 1)

    @style_button = gen_style_chooser_button
    attach(@style_button, 1, 1, 1, 1)

    button = gen_save_button
    attach(button, 2, 1, 1, 1)
    manage_buffer_changes
    manage_css_errors
    show_all
  end

  private

  def gen_source_view
    @view = GtkSource::View.new
    @manager = GtkSource::LanguageManager.new
    @language = @manager.get_language("css")
    @sm = GtkSource::StyleSchemeManager.default

    @view.show_line_numbers = true
    @view.insert_spaces_instead_of_tabs = true
    @view.buffer.language = @language
    @view.buffer.highlight_syntax = true
    @view.buffer.highlight_matching_brackets = true
    @view.buffer.text = @default_css
    @view.show_right_margin = true
    @view.right_margin_position = 80
    @view.smart_backspace = true
  end

  def gen_reset_button
    button = Gtk::Button.new(:label => "Reset")
    button.signal_connect "clicked" do
      @view.buffer.text = @default_css
    end
    button.vexpand = false
    button.hexpand = false
    button
  end

  def gen_style_chooser_button
    style_scheme = nil
    if @sm.scheme_ids.include?(@window.css_editor_style)
      style_scheme = @sm.get_scheme(@window.css_editor_style)
    else
      style_scheme = @sm.get_scheme("classic")
    end
    @view.buffer.style_scheme = style_scheme
    button = GtkSource::StyleSchemeChooserButton.new
    button.vexpand = false
    button.hexpand = true
    button.style_scheme = @view.buffer.style_scheme
    button.signal_connect "style-updated" do |widget|
      @view.buffer.style_scheme = widget.style_scheme
    end
    button
  end

  def gen_save_button
    button = Gtk::Button.new(:label => "Save")
    button.signal_connect "clicked" do
      @window.application.update_css
      reload_custom_css_properties
    end
    button.vexpand = false
    button.hexpand = false
    button
  end

  def manage_buffer_changes
    @view.buffer.signal_connect "changed" do |buffer|
      @modified_css = buffer.get_text(buffer.start_iter,
                                      buffer.end_iter,
                                      false)
      begin
        @provider.load_from_data(@modified_css)
      rescue
        @provider.load_from_data(@default_css)
      end

      reload_custom_css_properties
      Gtk::StyleContext.reset_widgets
      style_scheme = nil
      if @sm.scheme_ids.include?(@window.css_editor_style)
        style_scheme = @sm.get_scheme(@window.css_editor_style)
      else
        style_scheme = @sm.get_scheme("classic")
      end
      @view.buffer.style_scheme = style_scheme
      @style_button.style_scheme = style_scheme
    end
  end

  def manage_css_errors
    @provider.signal_connect "parsing-error" do |_css_provider, section, error|
      # @start_i = @view.buffer.get_iter_at(:line => section.start_line,
      #                                    :index => section.start_position)
      # @end_i =  @view.buffer.get_iter_at(:line => section.end_line,
      #                                   :index => section.end_position)
      # if error == Gtk::CssProviderError::DEPRECATED
      # else
      # end
    end
  end

  def reload_custom_css_properties
    reload_terminal_custom_css_properties
    reload_window_custom_css_properties
  end

  def reload_terminal_custom_css_properties
    @window.notebook.each do |tab|
      next unless tab.class == TopinambourTerminal
      colors = tab.get_css_colors unless colors
      tab.colors = colors
      tab.apply_colors
    end
  end

  def reload_window_custom_css_properties
    @window.load_css_properties
  end
end
