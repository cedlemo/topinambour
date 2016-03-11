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
class TopinambourNotebook < Gtk::Notebook
  attr_reader :visible
  attr_accessor :gen_preview
  def initialize
    super()
    @gen_preview = true
    signal_connect "hide" do
      @visible = false
    end
    signal_connect "show" do
      @visible = true
    end

    signal_connect "switch-page" do |_widget, next_page, next_page_num|
      toplevel.current_label.text = next_page.tab_label || get_tab_label(next_page).text
      toplevel.current_tab.text = "#{next_page_num + 1}/#{n_pages}"

      if page >= 0 && @gen_preview
        current.queue_draw
        _x, _y, w, h = current.allocation.to_a
        pix = current.window.to_pixbuf(0, 0, w, h)
        current.preview = pix if pix
      elsif !@gen_preview
        @gen_preview = true
      end
    end

    signal_connect "page-reordered" do
      toplevel.current_tab.text = "#{page + 1}/#{n_pages}"
    end

    signal_connect "page-removed" do
      toplevel.current_tab.text = "#{page + 1}/#{n_pages}" if toplevel.class == TopinambourWindow
    end

    set_show_tabs(false)
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
      current.grab_focus
    end
  end

  def toggle_visibility
    @visible ? hide : show
  end
end
