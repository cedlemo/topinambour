#!/usr/bin/env ruby
require "minitest/autorun"
require "fileutils"
require "sass"

PATH = File.expand_path(File.dirname("__FILE__"))
LIB_PATH = "#{PATH}/../lib"

require "#{LIB_PATH}/css_handler"
require "#{PATH}/test_files_ref"

class TestCssHandlerModule < MiniTest::Test
  include TestFilesRef

  def test_CssHandler_css_file?
    assert(CssHandler.css_file?(SIMPLE_CSS))
  end
  
  def test_CssHandler_scss_file?
    assert(CssHandler.scss_file?(SIMPLE_SCSS))
  end
  
  def test_CssHandler_sass_file?
    assert(CssHandler.sass_file?(SIMPLE_SASS))
  end
  
  def test_CssHandler_css_to_css
    content = File.open(SIMPLE_CSS, "r").read
    assert_equal(content, CssHandler.to_css(SIMPLE_CSS))

    content = File.open(INHERIT_CSS, "r").read
    assert_equal(content, CssHandler.to_css(INHERIT_CSS))
  
    content = File.open(COMMENTS_CSS, "r").read
    assert_equal(content, CssHandler.to_css(COMMENTS_CSS))
  end

  def test_CssHandler_color_property?
    assert_equal(true, CssHandler.color_property?("black"))
    assert_equal(false, CssHandler.color_property?("toto"))
    assert_equal(true, CssHandler.color_property?("rgb(0.5,0.6,0.4)"))
    assert_equal(true, CssHandler.color_property?("rgba(0.5,0.6,0.4, 0.0)"))
  end
end
