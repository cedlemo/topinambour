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
class TopinambourTermChooserb < Gtk::ScrolledWindow
  def initialize(window)
    super(nil, nil)
    @window = window
    set_size_request(800, @window.notebook.current.allocation.to_a[3] - 8)
    set_halign(:end)
    set_valign(:center)
    set_name("terminal_chooser")

    window.notebook.generate_tab_preview
    generate_list_store
    generate_tree_view
    @view.show_all
    @view.columns_autosize
    @view.name = "terms-list"
    generate_dnd_actions
    @box = Gtk::Box.new(:vertical, 4)
    @box.name = "overview-main-box"
    @box.pack_start(@view, :expand => false, :fill => false, :padding => 4)
    @box.pack_start(generate_quit_button,
                    :expand => false, :fill => false, :padding => 4)
    add(@box)
  end
  
  private
  def generate_list_store
    @model = Gtk::ListStore.new(String, GdkPixbuf::Pixbuf, String)
    @window.notebook.children.each_with_index do |child, i|
      iter = @model.append
      iter[0] = (i + 1).to_s
      iter[1] = generate_preview_image(child.preview)
      iter[2] = child.custom_title || child.terminal_title
    end
  end

  def generate_preview_image(pixbuf)
    pixbuf.scale(150, 75, :bilinear)
  end

  def generate_tree_view
    @view = Gtk::TreeView.new(@model)
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new("Index", renderer,
                                     :text => 0)
    @view.append_column(column)
    renderer = Gtk::CellRendererPixbuf.new
    column = Gtk::TreeViewColumn.new("View", renderer,
                                     :pixbuf => 1)
    @view.append_column(column)
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new("Title", renderer,
                                     :text => 2)
    @view.append_column(column)
  end
  
  def generate_dnd_actions
    target_table = [["GTK_TREE_MODEL_ROW", 0, 0]]
    @view.enable_model_drag_source(Gdk::ModifierType::BUTTON1_MASK,
                                  target_table,
                                  Gdk::DragAction::COPY | Gdk::DragAction::MOVE)
    @view.enable_model_drag_dest(target_table,
                                 Gdk::DragAction::COPY | Gdk::DragAction::MOVE)
    #@view.reorderable = true
  end
  
  def generate_quit_button
    button = Gtk::EventBox.new
    button.tooltip_text = "Quit Topinambour"
    image = Gtk::Image.new(:icon_name => "application-exit-symbolic",
                           :size => :dialog)
    button.add(image)
    button.signal_connect "button_press_event" do
      @window.quit_gracefully
    end
    button
  end
end
