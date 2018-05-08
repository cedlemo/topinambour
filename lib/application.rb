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

require "optparse"

class TopinambourApplication < Gtk::Application
  attr_accessor :settings
  def initialize
    @options = {}
    @exit_status = 0

    super("com.github.cedlemo.topinambour", [:non_unique,:handles_command_line])

    signal_connect "startup" do |application|
      ENV["GSETTINGS_SCHEMA_DIR"] = DATA_PATH
      @settings  = Gio::Settings.new("com.github.cedlemo.topinambour")

      initialize_css_provider
      load_css_config

    end

    signal_connect "activate" do |application|

      window = TopinambourWindow.new(application)

      if @options[:execute]
        window.add_terminal(@options[:execute])
      else
        window.add_terminal
      end
      window.show_all
      window.present
    end


    signal_connect "command-line" do |_application, command_line|
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

  private

  def parse_command_line(arguments)
    parser = OptionParser.new
    parser.on("-e", "--execute COMMAND", String, "Run a command") do |cmd|
      @options[:execute] = cmd
    end
    parser.parse(arguments)
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
    return unless @settings["custom-css"]
    css_file = check_css_file_path
    if css_file
      begin
        load_custom_css(css_file)
      rescue => e
        error_popup = TopinambourCssErrorPopup.new(windows.first)
        error_popup.message = e.message + "\n\nBad css file using default css"
        error_popup.show_all
      end
    else
      puts "No custom CSS, using default theme"
    end
  end

  def load_custom_css(file)
    if @settings["custom-css"]
      @css_content = File.open(file, "r").read
      @provider.load(:data => @css_content)
    else
      @provider.load(:data => "")
    end
  end

  def check_css_file_path
    css_file = if File.exist?(@settings["css-file"])
                 @settings["css-file"]
               else
                 "#{CONFIG_DIR}/#{@settings["css-file"]}"
               end
    File.exist?(css_file) ? css_file : nil
  end
end
