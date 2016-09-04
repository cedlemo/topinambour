# Copyright 2015-2016 Cedric LE MOIGNE, cedlemo@gmx.com
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
    generate_grid
    fill_grid

    @box = Gtk::Box.new(:vertical, 4)
    @box.name = "overview-main-box"
    @box.pack_start(@grid, :expand => true, :fill => true, :padding => 4)
    add(@box)
    set_size_request(-1, @window.notebook.current.allocation.to_a[3] - 8)
  end

  private

  def generate_grid
    @grid = Gtk::Grid.new
    @grid.row_spacing = 4
    @grid.column_spacing = 6
  end

  def fill_grid
    @window.notebook.children.each_with_index do |child, i|
      generate_row_grid(child, i)
    end
    @grid.attach(generate_separator, 0, @window.notebook.n_pages, 2, 1)
    button = generate_quit_button
    @grid.attach(button, 0, @window.notebook.n_pages + 1, 2, 1)
  end

  def generate_row_grid(term, index)
    button = Gtk::Label.new("tab. #{index + 1}")
    button.angle = 45
    @grid.attach(button, 0, index, 1, 1)
    button = generate_preview_button(term, index)
    @grid.attach(button, 1, index, 1, 1)
    add_drag_and_drop_functionalities(button)
    label = generate_label(term)
    @grid.attach(label, 2, index, 1, 1)
    button = generate_close_tab_button
    @grid.attach(button, 3, index, 1, 1)
  end

  def add_label_popup_entry_activate_signal(entry, popup, label, term)
    entry.signal_connect "activate" do |widget|
      label.text = widget.buffer.text
      term.custom_title = widget.buffer.text
      term.toplevel.current_label.text = widget.buffer.text
      popup.destroy
    end
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

  def generate_label_popup(label, event, term)
    entry = Gtk::Entry.new
    entry.max_width_chars = 50
    entry.buffer.text = label.text
    entry.set_icon_from_icon_name(:secondary, "edit-clear")
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

  def generate_close_tab_button
    button = Gtk::EventBox.new
    button.tooltip_text = "Close Tab"
    image = Gtk::Image.new(:icon_name => "window-close-symbolic",
                           :size => :button)
    button.add(image)
    button.hexpand = false
    button.vexpand = false
    button.valign = :start
    button.halign = :center
    button.signal_connect "button_press_event" do
      n = @grid.child_get_property(button, "top-attach")
      tab = @window.notebook.get_nth_page(n)
      if  @window.notebook.n_pages == 1
        @window.quit_gracefully
      else
        remove_tab(tab, n)
      end
    end
    button
  end

  def remove_tab(tab, n)
    @window.notebook.remove(tab)
    @grid.remove_row(n)
    last_tab = @window.notebook.n_pages - 1
    update_preview_button_tooltip(n..last_tab)
  end

  def update_preview_button_tooltip(range)
    range.each do |j|
      @grid.get_child_at(0, j).tooltip_text = j.to_s
    end
  end

  def generate_preview_button(child, i)
    button = Gtk::Button.new
    button.image = generate_preview_image(child.preview)
    button.set_tooltip_text((i + 1).to_s)
    button.signal_connect("clicked") { @window.notebook.current_page = i }
    button
  end

  def generate_preview_image(pixbuf)
    scaled_pix = pixbuf.scale(150, 75, :bilinear)
    img = Gtk::Image.new(:pixbuf => scaled_pix)
    img.show
    img
  end

  def generate_separator
    Gtk::Separator.new(:horizontal)
  end

  def generate_quit_button
    button = Gtk::EventBox.new
    button.tooltip_text = "Quit Topinambour"
    image = Gtk::Image.new(:icon_name => "application-exit-symbolic",
                           :size => :dialog)
    button.add(image)
    button.signal_connect("button_press_event") { @window.quit_gracefully }
    button
  end

  def add_drag_and_drop_functionalities(button)
    add_dnd_source(button)
    add_dnd_destination(button)
  end

  def add_dnd_source(button)
    button.drag_source_set(Gdk::ModifierType::BUTTON1_MASK |
                           Gdk::ModifierType::BUTTON2_MASK,
                           [["test", Gtk::TargetFlags::SAME_APP, 12_345]],
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
      index = grid_line_of(widget)
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
                         [["test", :same_app, 12_345]],
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
      index = grid_line_of(widget)
      index_of_dragged_object = index
      context.targets.each do |target|
        next unless target.name == "test" || selection_data.type == :type_integer
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
      @grid.get_child_at(1, i).image = generate_preview_image(child.preview)
      @grid.get_child_at(2, i).label = child.terminal_title
    end
  end

  def grid_line_of(widget)
    @grid.child_get_property(widget, "top-attach")
  end
end
