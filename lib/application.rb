# Copyright 2016-2018 Cedric LE MOIGNE, cedlemo@gmx.com
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

require 'optparse'
require 'fileutils'

## Gtk::Application class for topinambour
#
class TopinambourApplication < Gtk::Application
  attr_accessor :settings
  def initialize
    @options = {}
    @exit_status = 0
    @app_id = 'com.github.cedlemo.topinambour'
    @app_path = '/com/github/cedlemo/topinambour'

    super(@app_id, %i[non_unique handles_command_line])

    signal_connect 'startup' do |application|
      GLib.set_application_name('topinambour')
      GLib.set_prgname('topinambour')
      parent_schema = Gio::SettingsSchemaSource.default
      schema_source =
        Gio::SettingsSchemaSource.new(DATA_PATH, parent_schema, true)
      schema = schema_source.lookup(@app_id, true)
      @settings = Gio::Settings.new(schema: schema,
                                    path: @app_path + '/preferences/')

      TopinambourActions.add_actions_to(application)
      initialize_css_provider
      create_xdg_dirs
      load_css_config
      load_menu_ui(application)
    end

    signal_connect 'activate' do |application|
      window = TopinambourWindow.new(application)

      if @options[:execute]
        window.add_terminal(@options[:execute])
      else
        window.add_terminal
      end
      window.show_all
      window.present
    end

    signal_connect 'command-line' do |_application, command_line|
      begin
        parse_command_line(command_line.arguments)
      rescue SystemExit => error
        error.status
      rescue OptionParser::InvalidOption => error
        STDERR.puts error.message
        1
      rescue => error
        STDERR.puts "#{error.class}: #{error.message}"
        STDERR.puts error.backtrace
        1
      else
        activate
        @exit_status
      end
    end
  end

  def reload_css_config
    bad_css = nil
    css_file = check_css_file_path
    return unless css_file

    @provider.signal_connect 'parsing-error' do |_css_prov, section, _error|
      buf = Gtk::TextBuffer.new
      buf.text = @css_content
      start_i = buf.get_iter_at(line: section.start_line,
                                index: section.start_position)
      end_i = buf.get_iter_at(line: section.start_line + 10,
                              index: section.end_position)
      bad_css = ''
      buf.get_text(start_i, end_i, true).lines.each_with_index do |line, i|
        bad_css += "#{section.start_line + 1 + i}  #{line}"
      end
    end

    begin
      load_custom_css(css_file)
    rescue => e
      windows.first.exit_overlay_mode
      # TODO : deal with the preferences window which is a transient one
      # that keeps the focus even when the popup shows up.
      error_popup = TopinambourCssErrorPopup.new(windows.first)
      error_popup.transient_for = windows.first
      error_popup.message = e.message + "\n\n" + bad_css
      error_popup.show_all
    end
  end

  def check_css_file_path
    css_file = if File.exist?(@settings['css-file'])
                 @settings['css-file']
               else
                 "#{CONFIG_DIR}/#{@settings['css-file']}"
               end
    File.exist?(css_file) ? css_file : nil
  end

  private

  def parse_command_line(arguments)
    parser = OptionParser.new
    parser.on('-e', '--execute COMMAND', String, 'Run a command') do |cmd|
      @options[:execute] = cmd
    end
    parser.parse(arguments)
  end

  def load_menu_ui(application)
    builder = Gtk::Builder.new(resource: @app_path + '/app-menu.ui')
    app_menu = builder['appmenu']
    application.app_menu = app_menu
  end

  #########################
  # CSS related functions #
  #########################

  def initialize_css_provider
    screen = Gdk::Display.default.default_screen
    @provider = Gtk::CssProvider.new
    Gtk::StyleContext.add_provider_for_screen(screen,
                                              @provider,
                                              Gtk::StyleProvider::PRIORITY_USER)
  end

  def load_css_config
    return unless @settings['custom-css']
    if (css_file = check_css_file_path)
      begin
        load_custom_css(css_file)
      rescue => e
        error_popup = TopinambourCssErrorPopup.new(windows.first)
        error_popup.message = e.message + "\n\nBad css file using default css"
        error_popup.show_all
      end
    else
      puts 'No custom CSS, using default theme'
    end
  end

  def load_custom_css(file)
    if @settings['custom-css']
      @css_content = File.open(file, 'r').read
      @provider.load(data: @css_content)
    else
      @provider.load(data: '')
    end
  end

  #########################
  # Misc                  #
  #########################
  def create_xdg_dirs
    create_dir_if_absent(CONFIG_DIR)
    create_dir_if_absent(DATA_HOME_DIR)
  end

  def create_dir_if_absent(path)
    FileUtils.mkdir_p path unless File.exist?(path)
  end
end

class TopinambourCssErrorPopup < Gtk::MessageDialog

  def initialize(parent)
    super(:parent => parent, :flags => 0,
          :type => Gtk::MessageType::ERROR,
          :buttons_type => Gtk::ButtonsType::CLOSE,
          :message => "Css Error")

    @message = Gtk::Label.new("")
    content_area.add(@message)
    signal_connect("response") { |widget| widget.destroy }
  end

  def message=(message)
    @message.text = message
  end

  def message
    @message.text
  end
end
