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
class TopinambourTermChooser < Gtk::ScrolledWindow
  def initialize(window)
    super(nil, nil)
    @window = window
    set_size_request(184, @window.notebook.current.allocation.to_a[3] - 8)
    set_halign(:end)
    set_valign(:center)
    set_name("terminal_chooser")

    window.notebook.generate_tab_preview
    generate_grid
    fill_grid

    @box = Gtk::Box.new(:vertical, 4)
    @box.pack_start(@grid, :expand => true, :fill => true, :padding => 4)
    add(@box)
  end

  private

  def generate_grid
    @grid = Gtk::Grid.new
    @grid.valign = :start
    @grid.halign = :center
    @grid.row_spacing = 2
  end

  def fill_grid
    @window.notebook.children.each_with_index do |child, i|
      button = generate_preview_button(child, i)
      @grid.attach(button, 0, i, 1, 1)
      add_drag_and_drop_functionalities(button)
      button = generate_close_tab_button
      @grid.attach(button, 1, i, 1, 1)
    end
    @grid.attach(generate_separator, 0, @window.notebook.n_pages, 2, 1)
    button = generate_quit_button
    @grid.attach(button, 0, @window.notebook.n_pages + 1, 2, 1)
  end

  def generate_close_tab_button
    button = Gtk::EventBox.new
    button.tooltip_text = "Close Tab"
    image = Gtk::Image.new(:icon_name => "window-close-symbolic", :size => :button)
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
    (range).each do |j|
      puts j
      @grid.get_child_at(0, j).tooltip_text = j.to_s
    end
  end

  def generate_preview_button(child, i)
    button = Gtk::Button.new
    button.add(generate_preview_image(child.preview))
    button.set_tooltip_text(i.to_s)
    button.signal_connect("clicked") { @window.notebook.current_page = i }
    button
  end

  def generate_preview_image(pixbuf)
    scaled_pix = pixbuf.scale(150, 75, Gdk::Pixbuf::INTERP_BILINEAR)
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
    image = Gtk::Image.new(:icon_name => "application-exit-symbolic", :size => :dialog)
    button.add(image)
    button.signal_connect "button_press_event" do
      @window.quit_gracefully
    end
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
    button.drag_source_set_icon_name("grab")
    # Drag source signals
    # drag-begin	User starts a drag	Set-up drag icon
    # drag-data-get	When drag data is requested by the destination	Transfer drag data from source to destination
    # drag-data-delete	When a drag with the action Gdk.DragAction.MOVE is completed	Delete data from the source to complete the "move"
    # drag-end	When the drag is complete	Undo anything done in drag-begin

    # button.signal_connect "drag-begin" do
    #   puts "drag begin for #{index}"
    # end
    button.signal_connect("drag-data-get") do |_widget, _context, selection_data, _info, _time|
      index = @grid.child_get_property(button, "top-attach")
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
    # drag-motion	Drag icon moves over a drop area	Allow only certain areas to be dropped onto
    # drag-drop	Icon is dropped onto a drag area	Allow only certain areas to be dropped onto
    # drag-data-received	When drag data is received by the destination	Transfer drag data from source to destination
    # button.signal_connect "drag-motion" do
    #   puts "drag motion for #{index}"
    # end
    button.signal_connect("drag-drop") do |widget, context, _x, _y, time|
      widget.drag_get_data(context, context.targets[0], time)
    end
    button.signal_connect("drag-data-received") do |_widget, context, _x, _y, selection_data, _info, _time|
      index = @grid.child_get_property(button, "top-attach")
      index_of_dragged_object = index
      context.targets.each do |target|
        next unless target.name == "test" || selection_data.type == :type_integer
        data_len = selection_data.data[1]
        index_of_dragged_object = selection_data.data[0].pack("C#{data_len}").to_i
      end
      if index_of_dragged_object != index
        dragged = @window.notebook.get_nth_page(index_of_dragged_object)
        @window.notebook.reorder_child(dragged, index)
        @window.notebook.children.each_with_index do |child, i|
          @grid.get_child_at(0, i).image = generate_preview_image(child.preview)
        end
      end
    end
  end
end
