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
class TopinambourNotebook < Gtk::Notebook
  attr_reader :visible, :hidden

  def initialize
    super()
    @hidden = []
    signal_connect("hide") { @visible = false }

    signal_connect("show") { @visible = true }

    signal_connect "switch-page" do |_widget, next_page, next_page_num|
      toplevel.current_label.text = next_page.term.terminal_title
      toplevel.current_tab.text = "#{next_page_num + 1}/#{n_pages}"
      generate_tab_preview if page >= 0
    end

    signal_connect "page-reordered" do
      toplevel.current_tab.text = "#{page + 1}/#{n_pages}"
    end

    signal_connect "page-removed" do |_widget, _child, page_num|
      if toplevel.class == TopinambourWindow
        toplevel.current_tab.text = "#{page + 1}/#{n_pages}"
      end
    end
    set_name("topinambour-notebook")
    set_show_tabs(false)
    set_show_border(false)
  end

  def remove_all_pages
    each do |widget|
      index = page_num(widget)
      remove_page(index)
    end
  end

  def cycle_next_page
    page < (n_pages - 1) ? next_page : set_page(0)
  end

  def cycle_prev_page
    page > 0 ? prev_page : set_page(n_pages - 1)
  end

  def current
    get_nth_page(page)
  end

  def remove_current_page
    if n_pages == 1
      toplevel.quit_gracefully
    else
      remove(current)
      current.term.grab_focus
    end
  end

  def toggle_visibility
    @visible ? hide : show
  end

  def generate_tab_preview
    _x, _y, w, h = current.term.allocation.to_a
    surface = Cairo::ImageSurface.new(Cairo::FORMAT_ARGB32,
                                      w, h)
    cr = Cairo::Context.new(surface)
    current.term.draw(cr)
    pix = surface.to_pixbuf(0, 0, w, h)
    current.term.preview = pix if pix
  end

  def send_to_all_terminals(method_name, values)
    each do |tab|
      tab.term.send(method_name, *values)
    end
  end

  def hide(index)
    child = get_nth_page(index)
    @hidden << child
    remove_page(index)
  end

  def unhide(index)
    append_page(@hidden[index])
    toplevel.current_tab.text = "#{current_page + 1}/#{n_pages}"
  end
end
