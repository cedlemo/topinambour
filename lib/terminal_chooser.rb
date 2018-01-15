# Copyright 2017-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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
    @notebook = @window.notebook
    @notebook.generate_tab_preview
    initialize_list_box
    initialize_hidden_list_box
    initialize_main_box
    configure_window
  end

  private

  def configure_window
    set_halign(:end)
    set_valign(:center)
    set_policy(:never, :automatic)
    set_name("terminal_chooser")
    add(@box)
    set_size_request(-1, @notebook.current.term.allocation.to_a[3] - 8)
  end

  def initialize_main_box
    @box = Gtk::Box.new(:vertical, 4)
    @box.name = "topinambour-overview-box"
    @box.pack_start(main_title, :expand => false, :fill => true, :padding => 6)
    @box.pack_start(@listbox, :expand => true, :fill => true, :padding => 12)
    @box.pack_start(box_title("Hidden terminals"),
                    :expand => false, :fill => true, :padding => 6)
    @box.pack_start(@listbox_hidden, :expand => true, :fill => true,
                                     :padding => 12)
  end

  def main_title
    hbox = Gtk::Box.new(:horizontal, 6)
    hbox.pack_start(box_title("Terminals"),
                    :expand => true, :fill => true, :padding => 6)
    hbox.pack_start(box_close_button,
                    :expand => false, :fill => false, :padding => 6)
    hbox
  end

  def box_title(label)
    title = Gtk::Label.new("> #{label} :")
    title.halign = :start
    title
  end

  def box_close_button
    button = Gtk::Button.new(:icon_name => "window-close-symbolic",
                             :size => :button)
    button.relief = :none
    button.signal_connect("clicked") { @window.exit_overlay_mode }
    button
  end

  def initialize_list_box
    @listbox = Gtk::ListBox.new
    @listbox.margin = 12
    @listbox.selection_mode = :single
    fill_list_box
  end

  def initialize_hidden_list_box
    @listbox_hidden = Gtk::ListBox.new
    @listbox_hidden.placeholder = Gtk::Label.new("Hidden terminals")
    @listbox_hidden.margin = 12
    @listbox_hidden.show_all
    @listbox_hidden.selection_mode = :single
    fill_hidden_list_box
  end

  def fill_list_box
    @listbox.signal_connect "row-selected" do |_list, row|
      @notebook.current_page = row.nil? ? @notebook.children.size : row.index
    end

    @notebook.children.each_with_index do |child, i|
      row = generate_list_box_row(child.term, i)
      @listbox.insert(row, i)
      row.close_button.signal_connect "clicked" do |widget|
        close_button_action(widget)
      end
    end
    current_row = @listbox.get_row_at_index(@notebook.current_page)
    @listbox.select_row(current_row)
    current_row.grab_focus
  end

  def fill_hidden_list_box
    @notebook.hidden.each_with_index do |child, i|
      row = generate_hidden_list_box_row(child.term, i)
      @listbox_hidden.insert(row, i)
      row.close_button.signal_connect "clicked" do |widget|
        close_button_action(widget)
      end
    end
  end

  def close_button_action(button)
    row = button.parent.parent
    listbox = row.parent
    if listbox == @listbox
      tab = @notebook.get_nth_page(row.index)
      @notebook.n_pages == 1 ? @window.quit_gracefully : @notebook.remove(tab)
      row.destroy
      update_tabs_num_labels
    elsif listbox == @listbox_hidden
      @notebook.hidden.delete_at(row.index)
      row.destroy
      update_tabs_num_labels
    end
  end

  def generate_list_box_row(term, index)
    list_box_row = ChooserListRow.new(term, index, @notebook)
    generate_hide_button(list_box_row)
  end

  def generate_hidden_list_box_row(term, index)
    list_box_row = ChooserListRow.new(term, index, @notebook)
    generate_show_button(list_box_row)
    preview_action_for_hidden_list(list_box_row)
  end

  def generate_show_button(list_box_row)
    list_box_row.generate_new_action_button("Show")
    list_box_row.action_button.signal_connect "clicked" do
      tab_num = list_box_row.index
      @window.notebook.unhide(tab_num)
      list_box_row_bkp = generate_hide_button(list_box_row)
      @listbox_hidden.remove(list_box_row)
      @listbox.insert(list_box_row_bkp, -1)
      update_tabs_num_labels
      preview_action_for_shown_list(list_box_row_bkp)
    end
    list_box_row
  end

  def preview_action_for_hidden_list(list_box_row)
    list_box_row.preview_button.signal_connect "clicked" do
      tab_num = list_box_row.index
      @window.notebook.unhide(tab_num)
      list_box_row_bkp = generate_hide_button(list_box_row)
      @listbox_hidden.remove(list_box_row)
      @listbox.insert(list_box_row_bkp, -1)
      @notebook.current_page = (@listbox.children.length - 1)
      update_tabs_num_labels
      preview_action_for_shown_list(list_box_row_bkp)
    end
    list_box_row
  end

  def preview_action_for_shown_list(list_box_row)
    list_box_row.preview_button.signal_connect "clicked" do
      @notebook.current_page = list_box_row.index
    end
    list_box_row
  end

  def generate_hide_button(list_box_row)
    list_box_row.generate_new_action_button("Hide")
    list_box_row.action_button.signal_connect "clicked" do
      num = list_box_row.index
      @notebook.n_pages == 1 ? @window.quit_gracefully : @notebook.hide(num)
      list_box_row_bkp = generate_show_button(list_box_row)
      preview_action_for_hidden_list(list_box_row_bkp)
      @listbox.remove(list_box_row)
      @listbox_hidden.insert(list_box_row_bkp, -1)
      update_tabs_num_labels
    end
    list_box_row
  end

  def update_tabs_num_labels
    @listbox.children.each_with_index do |row, i|
      hbox = row.children[0]
      label = hbox.children[0]
      label.text = "tab. #{i + 1}"
    end
    update_hidden_tabs_num_labels
  end

  def update_hidden_tabs_num_labels
    @listbox_hidden.children.each_with_index do |row, i|
      hbox = row.children[0]
      label = hbox.children[0]
      label.text = "tab. #{i + 1}"
    end
  end
end

class ChooserListRow < Gtk::ListBoxRow
  attr_reader :close_button
  def initialize(term, index, notebook)
    super()
    @notebook = notebook
    @hbox = Gtk::Box.new(:horizontal, 6)
    fill_hbox_list_box_row(term, index)
    generate_action_button
    add(@hbox)
  end

  def action_button
    @hbox.children[4]
  end

  def preview_button
    @prev_button
  end

  def generate_new_action_button(label)
    button = Gtk::Button.new(:label => label)
    button.valign = :center
    button.vexpand = false
    @hbox.remove(action_button)
    @hbox.pack_start(button,
                     :expand => false, :fill => false, :padding => 6)
    show_all
  end

  private

  def fill_hbox_list_box_row(term, index)
    label = leaning_label(index)
    @hbox.pack_start(label, :expand => false, :fill => false, :padding => 6)
    @prev_button = PreviewButton.new(term, @notebook)
    @hbox.pack_start(@prev_button, :expand => false, :fill => false, :padding => 6)
    label = EditableLabel.new(term)
    @hbox.pack_start(label, :expand => true, :fill => false, :padding => 6)
    generate_close_button
    @hbox.pack_start(@close_button, :expand => false, :fill => false, :padding => 6)
    @hbox
  end

  def leaning_label(index)
    label = Gtk::Label.new("tab. #{index + 1}")
    label.angle = 45
    label
  end

  def generate_close_button
    @close_button = Gtk::Button.new(:icon_name => "window-close-symbolic",
                                    :size => :button)
    @close_button.relief = :none
  end

  def generate_action_button
    action_button = Gtk::Button.new(:label => "")
    action_button.valign = :center
    action_button.vexpand = false
    @hbox.pack_start(action_button,
                     :expand => false, :fill => false, :padding => 6)
  end
end

class PreviewButton < Gtk::Button
  def initialize(term, notebook)
    super()
    self.image = generate_preview_image(term.preview)
    # TODO: remove ?
    @notebook = notebook
    signal_connect "clicked" do
      @notebook.current_page = index if parent.class == Gtk::ListBox
    end
    add_dnd_functionalities
  end

  private

  def generate_preview_image(pixbuf)
    scaled_pix = pixbuf.scale(200, 100, :bilinear)
    img = Gtk::Image.new(:pixbuf => scaled_pix)
    img.show
    img
  end

  def add_dnd_functionalities
    add_dnd_source
    add_dnd_destination
  end

  def add_dnd_source
    drag_source_set(Gdk::ModifierType::BUTTON1_MASK |
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

    signal_connect "drag-begin" do |widget|
      widget.drag_source_set_icon_pixbuf(widget.image.pixbuf)
    end

    signal_connect "drag-data-get" do |widget, _, selection_data, _, _|
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

  def add_dnd_destination
    drag_dest_set(Gtk::DestDefaults::MOTION |
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
    signal_connect "drag-drop" do |widget, context, _x, _y, time|
      widget.drag_get_data(context, context.targets[0], time)
    end

    signal_connect("drag-data-received") do |widget, context, _x, _y, selection_data|
      index = widget.parent.parent.index
      index_of_dragged_object = index
      context.targets.each do |target|
        next unless target.name == "drag_term" ||
                    selection_data.type == :type_integer
        data_len = selection_data.data.size
        index_of_dragged_object = selection_data.data.pack("C#{data_len}").to_i
      end
      if index_of_dragged_object != index
        drag_image_and_reorder_terms(index_of_dragged_object, index)
      end
    end
  end

  def listbox_ancestor
    ancestor = parent
    loop do
      ancestor = ancestor.parent
      break if ancestor.is_a? Gtk::ListBox
    end
    ancestor
  end

  def drag_image_and_reorder_terms(src_index, dest_index)
    dragged = @notebook.get_nth_page(src_index)
    @notebook.reorder_child(dragged, dest_index)
    @notebook.children.each_with_index do |child, i|
      list_box_row = listbox_ancestor.get_row_at_index(i)
      row_h_box = list_box_row.children[0]
      row_h_box.children[1].image = generate_preview_image(child.term.preview)
      row_h_box.children[2].text = child.term.terminal_title
    end
  end
end

class EditableLabel < Gtk::Label
  def initialize(term)
    super(term.terminal_title)
    set_halign(:start)
    set_selectable(true)
    signal_connect "button-release-event" do |w, e|
      generate_label_popup(w, e, term)
    end
    label
  end

  def generate_label_popup(label, event, term)
    initialize_entry_popup(label)
    @popup = Gtk::Popover.new
    add_label_popup_entry_activate_signal(label, term)
    add_label_popup_entry_icon_release(label, term)
    @popup.add(@entry)
    set_popup_position(label, event)
  end

  def initialize_entry_popup(label)
    @entry = Gtk::Entry.new
    @entry.max_width_chars = 50
    @entry.buffer.text = label.text
    @entry.set_icon_from_icon_name(:secondary, "edit-clear-symbolic")
  end

  def add_label_popup_entry_icon_release(label, term)
    @entry.signal_connect "icon-release" do |widget, position|
      if position == :secondary
        term.custom_title = nil
        label.text = term.window_title
        term.toplevel.current_label.text = label.text
        widget.buffer.text = label.text
      end
    end
  end

  def add_label_popup_entry_activate_signal(label, term)
    @entry.signal_connect "activate" do |widget|
      label.text = widget.buffer.text
      term.custom_title = widget.buffer.text
      @popup.destroy
    end
  end

  def set_popup_position(label, event)
    x, y = event.window.coords_to_parent(event.x, event.y)
    rect = Gdk::Rectangle.new(x - label.allocation.x, y - label.allocation.y,
                              1, 1)
    @popup.pointing_to = rect
    @popup.relative_to = label
    @popup.show_all
  end
end
