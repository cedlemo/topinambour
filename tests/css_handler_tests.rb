#!/usr/bin/env ruby
require "minitest/autorun"
require "fileutils"

PATH = File.expand_path(File.dirname("__FILE__"))
LIB_PATH = "#{PATH}/../lib"

require "#{LIB_PATH}/css_handler"

class TestCssHandlerModule < MiniTest::Test
  def test_CssHandler_css_file?
    assert(CssHandler.css_file?("#{PATH}/file1.css"))
  end
  def test_CssHandler_scss_file?
    assert(CssHandler.scss_file?("#{PATH}/file1.scss"))
  end
  def test_CssHandler_sass_file?
    assert(CssHandler.sass_file?("#{PATH}/file1.sass"))
  end
end
