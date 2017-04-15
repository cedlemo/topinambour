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
    @listbox_hidden = Gtk::ListBox.new
    hidden_title = Gtk::Label.new("Hidden terminals")
    @listbox_hidden.placeholder = hidden_title
    @listbox_hidden.margin = 12
    @listbox_hidden.show_all
    fill_list_box

    @box = Gtk::Box.new(:vertical, 4)
    @box.name = "topinambour-overview-box"
    hbox = Gtk::Box.new(:horizontal, 6)
    title = Gtk::Label.new("> Terminals :")
    title.halign = :start
    hbox.pack_start(title, :expand => true, :fill => true, :padding => 6)
    close_button = Gtk::Button.new(:icon_name => "window-close-symbolic",
                                   :size => :button)
    close_button.relief = :none
    close_button.signal_connect "clicked" do
      @window.exit_overlay_mode
    end
    hbox.pack_start(close_button, :expand => false, :fill => false, :padding => 6)
    @box.pack_start(hbox, :expand => false, :fill => true, :padding => 6)
    @listbox.margin = 12
    @box.pack_start(@listbox, :expand => true, :fill => true, :padding => 12)
    hidden_title = Gtk::Label.new("> Hidden terminals :")
    hidden_title.halign = :start
    @box.pack_start(hidden_title, :expand => false, :fill => true, :padding => 6)
    @box.pack_start(@listbox_hidden, :expand => true, :fill => true, :padding => 12)
    add(@box)
    set_size_request(-1, @window.notebook.current.term.allocation.to_a[3] - 8)
  end

  private

  def fill_list_box
    @listbox.selection_mode = :single
    @listbox.signal_connect "row-selected" do |list, row|
      index = row.nil? ? @window.notebook.children.size : row.index
      @window.notebook.current_page = index
    end

    @window.notebook.children.each_with_index do |child, i|
      row = generate_list_box_row(child.term, i)
      @listbox.insert(row, i)
    end
    current_row = @listbox.get_row_at_index(@window.notebook.current_page)
    @listbox.select_row(current_row)
    current_row.grab_focus
  end

  def generate_list_box_row(term, index)
    list_box_row = Gtk::ListBoxRow.new
    hbox = Gtk::Box.new(:horizontal, 6)
    button = Gtk::Label.new("tab. #{index + 1}")
    button.angle = 45
    hbox.pack_start(button, :expand => false, :fill => false, :padding => 6)
    button = generate_preview_button(term, list_box_row)
    add_drag_and_drop_functionalities(button)
    hbox.pack_start(button, :expand => false, :fill => false, :padding => 6)
    label = generate_label(term)
    hbox.pack_start(label, :expand => true, :fill => false, :padding => 6)
    button = generate_close_tab_button(list_box_row)
    hbox.pack_start(button, :expand => false, :fill => false, :padding => 6)
    button = generate_hide_button(list_box_row)
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
    # scaled_pix = pixbuf.scale(150, 75, :bilinear)
    scaled_pix = pixbuf.scale(200, 100, :bilinear)
    img = Gtk::Image.new(:pixbuf => scaled_pix)
    img.show
    img
  end

  def generate_hide_button(list_box_row)
    button = Gtk::Button.new(:label => "Hide")
    button.valign = :center
    button.vexpand = false
    button.signal_connect "clicked" do |widget|
      tab_num = list_box_row.index
      if  @window.notebook.n_pages == 1
        @window.quit_gracefully
      else
        @window.notebook.hide(tab_num)
      end
      list_box_row_bkp = list_box_row
      container = list_box_row_bkp.children[0]
      hide_button = list_box_row_bkp.children[0].children[4]
      container.remove(hide_button)
      show_button = generate_show_button(list_box_row_bkp)
      show_button.show
      container.pack_start(show_button, :expand => false, :fill => false, :padding => 6)

      @listbox.remove(list_box_row)
      @listbox_hidden.insert(list_box_row_bkp, -1)
      update_tabs_num_labels
    end
    button
  end

  def generate_show_button(list_box_row)
    button = Gtk::Button.new(:label => "Show")
    button.valign = :center
    button.vexpand = false
    button.signal_connect "clicked" do |widget|
      tab_num = list_box_row.index
      @window.notebook.unhide(tab_num)
      list_box_row_bkp = list_box_row
      container = list_box_row_bkp.children[0]
      show_button = list_box_row_bkp.children[0].children[4]
      container.remove(show_button)
      hide_button = generate_hide_button(list_box_row_bkp)
      hide_button.show
      container.pack_start(hide_button, :expand => false, :fill => false, :padding => 6)

      @listbox_hidden.remove(list_box_row)
      @listbox.insert(list_box_row_bkp, -1)
      update_tabs_num_labels
    end
    button
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

  def add_drag_and_drop_functionalities(button)
    add_dnd_source(button)
    add_dnd_destination(button)
  end

  def add_dnd_source(button)
    button.drag_source_set(Gdk::ModifierType::BUTTON1_MASK |
                           Gdk::ModifierType::BUTTON2_MASK,
                           [["drag_term", Gtk::TargetFlags::SAME_APP, 12_345]],
                           Gdk::DragAction::COPY |
                           Gdk::DragAction::MOVE)
    # Drag source signals
    # drag-begin	User starts a drag	Set-up drag icon
    # drag-data-get	When drag data is requested by the destination	Transfer
    # drag data from source to destination
    # drag-data-delete	When a drag with the action Gdk.DragAction.MOVE is
    # completed	Delete data from the source to complete the "move"
    # drag-end	When the drag is complete	Undo anything done in drag-begin

    button.signal_connect "drag-begin" do |widget|
      widget.drag_source_set_icon_pixbuf(widget.image.pixbuf)
    end

    button.signal_connect("drag-data-get") do |widget, _, selection_data, _, _|
      index = widget.parent.parent.index
      selection_data.set(Gdk::Selection::TYPE_INTEGER, index.to_s)
    end
    # button.signal_connect "drag-data-delete" do
    #   puts "drag data delete for #{inex}"
    # end
    # button.signal_connect "drag-end" do
    #   puts "drag end for #{index}"
    # end
  end

  def add_dnd_destination(button)
    button.drag_dest_set(Gtk::DestDefaults::MOTION |
                         Gtk::DestDefaults::HIGHLIGHT,
                         [["drag_term", :same_app, 12_345]],
                         Gdk::DragAction::COPY |
                         Gdk::DragAction::MOVE)

    # Drag destination signals
    # drag-motion	Drag icon moves over a drop area	Allow only certain areas to
    # be dropped onto drag-drop	Icon is dropped onto a drag area	Allow only
    # certain areas to be dropped onto drag-data-received	When drag data is
    # received by the destination	Transfer drag data from source to destination
    # button.signal_connect "drag-motion" do
    #   puts "drag motion for #{index}"
    # end
    button.signal_connect("drag-drop") do |widget, context, _x, _y, time|
      widget.drag_get_data(context, context.targets[0], time)
    end

    button.signal_connect("drag-data-received") do |widget, context, _x, _y, selection_data|
      index = widget.parent.parent.index
      index_of_dragged_object = index
      context.targets.each do |target|
        next unless target.name == "drag_term" || selection_data.type == :type_integer
        data_len = selection_data.data.size
        index_of_dragged_object = selection_data.data.pack("C#{data_len}").to_i
      end
      if index_of_dragged_object != index
        drag_image_and_reorder_terms(index_of_dragged_object, index)
      end
    end
  end

  def drag_image_and_reorder_terms(src_index, dest_index)
    dragged = @window.notebook.get_nth_page(src_index)
    @window.notebook.reorder_child(dragged, dest_index)
    @window.notebook.children.each_with_index do |child, i|
      list_box_row = @listbox.get_row_at_index(i)
      row_h_box = list_box_row.children[0]
      row_h_box.children[1].image = generate_preview_image(child.term.preview)
      row_h_box.children[2].text = child.term.terminal_title
    end
  end

end
