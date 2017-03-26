# Copyright 2017 Cedric LE MOIGNE, cedlemo@gmx.com
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
class TopinambourTermChooser < Gtk::ScrolledWindow
  def initialize(window)
    super(nil, nil)
    @window = window
    set_halign(:end)
    set_valign(:center)
    set_policy(:never, :automatic)
    set_name("terminal_chooser")

    window.notebook.generate_tab_preview
    @listbox = Gtk::ListBox.new
    fill_list_box

    @box = Gtk::Box.new(:vertical, 4)
    @box.name = "topinambour-overview-box"
    @box.pack_start(@listbox, :expand => true, :fill => true, :padding => 12)
    add(@box)
    set_size_request(-1, @window.notebook.current.term.allocation.to_a[3] - 8)
  end

  private

  def fill_list_box
    @window.notebook.children.each_with_index do |child, i|
      row = generate_list_box_row(child.term, i)
      @listbox.insert(row, i)
    end
  end

  def generate_list_box_row(term, index)
    list_box_row = Gtk::ListBoxRow.new
    hbox = Gtk::Box.new(:horizontal, 6)
    button = Gtk::Label.new("tab. #{index + 1}")
    button.angle = 45
    hbox.pack_start(button, :expand => false, :fill => false, :padding => 6)
    button = generate_preview_button(term, list_box_row)
    hbox.pack_start(button, :expand => false, :fill => false, :padding => 6)
    label = generate_label(term)
    hbox.pack_start(label, :expand => true, :fill => false, :padding => 6)
    button = generate_close_tab_button(list_box_row)
    hbox.pack_start(button, :expand => false, :fill => false, :padding => 6)
    list_box_row.add(hbox)
  end

  def generate_preview_button(child, list_box_row)
    button = Gtk::Button.new
    button.image = generate_preview_image(child.preview)
    button.signal_connect "clicked" do |widget|
      @window.notebook.current_page = list_box_row.index
    end
    button
  end

  def generate_preview_image(pixbuf)
    scaled_pix = pixbuf.scale(150, 75, :bilinear)
    img = Gtk::Image.new(:pixbuf => scaled_pix)
    img.show
    img
  end

  def generate_close_tab_button(list_box_row)
    button = Gtk::Button.new(:icon_name => "window-close-symbolic",
                           :size => :button)
    button.relief = :none
    button.signal_connect "clicked" do |widget|
      tab = @window.notebook.get_nth_page(list_box_row.index)
      if  @window.notebook.n_pages == 1
        @window.quit_gracefully
      else
        @window.notebook.remove(tab)
      end
      list_box_row.destroy
      update_tabs_num_labels
    end
    button
  end

  def add_label_popup_entry_icon_release(entry, label, term)
    entry.signal_connect "icon-release" do |widget, position|
      if position == :secondary
        term.custom_title = nil
        label.text = term.window_title
        term.toplevel.current_label.text = label.text
        widget.buffer.text = label.text
      end
    end
  end

  def add_label_popup_entry_activate_signal(entry, popup, label, term)
    entry.signal_connect "activate" do |widget|
      label.text = widget.buffer.text
      term.custom_title = widget.buffer.text
      term.toplevel.current_label.text = widget.buffer.text
      popup.destroy
    end
  end

  def generate_label_popup(label, event, term)
    entry = Gtk::Entry.new
    entry.max_width_chars = 50
    entry.buffer.text = label.text
    entry.set_icon_from_icon_name(:secondary, "edit-clear-symbolic")
    pp = Gtk::Popover.new
    add_label_popup_entry_activate_signal(entry, pp, label, term)
    add_label_popup_entry_icon_release(entry, label, term)

    pp.add(entry)
    x, y = event.window.coords_to_parent(event.x, event.y)
    rect = Gdk::Rectangle.new(x - label.allocation.x, y - label.allocation.y,
                              1, 1)
    pp.pointing_to = rect
    pp.relative_to = label
    pp.show_all
  end

  def generate_label(term)
    label = Gtk::Label.new(term.terminal_title)
    label.halign = :start
    label.selectable = true
    label.signal_connect "button-release-event" do |w, e|
      generate_label_popup(w, e, term)
    end
    label
  end

  def update_tabs_num_labels
    @listbox.children.each_with_index do |row, i|
      hbox = row.children[0]
      label = hbox.children[0]
      label.text = "tab. #{i + 1}"
    end
  end
end

