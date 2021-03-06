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

  def test_CssHandler_props_with_name
    engine = CssHandler.to_engine(SIMPLE_CSS)
    tree = engine.to_tree
    props = CssHandler.props_with_name(tree, "border-radius")
    assert_equal(2, props.size)
    assert_equal(2, props[0].line)
    assert_equal(8, props[1].line)

    source_range = props[0].source_range
    s = source_range.start_pos
    e = source_range.end_pos
    assert_equal(3, s.offset)
    assert_equal(21, e.offset)

    source_range = props[1].source_range
    s = source_range.start_pos
    e = source_range.end_pos
    assert_equal(3, s.offset)
    assert_equal(33, e.offset)

    engine = CssHandler.to_engine(COMMENTS_CSS)
    tree = engine.to_tree
    props = CssHandler.props_with_name(tree, "border-radius")
    assert_equal(1, props.size)
    source_range = props[0].source_range
    s = source_range.start_pos
    e = source_range.end_pos
    assert_equal(3, s.offset)
    assert_equal(21, e.offset)
  end
  
  def test_CssHandler_prop_position
    engine = CssHandler.to_engine(SIMPLE_CSS)
    tree = engine.to_tree
    props = CssHandler.props_with_name(tree, "border-radius")
    assert_equal(2, props.size)
    start_line = CssHandler.prop_position(props[0])[0].line
    end_line = CssHandler.prop_position(props[0])[1].line
    start_pos = CssHandler.prop_position(props[0])[0].offset
    end_pos = CssHandler.prop_position(props[0])[1].offset
    assert_equal(2, start_line)
    assert_equal(3, start_pos)
    assert_equal(2, end_line)
    assert_equal(21, end_pos)
  end
  
  def test_CssHandler_selectors_with_name
    engine = CssHandler.to_engine(UNIVERSAL_SEL_CSS)
    tree = engine.to_tree
    selectors = CssHandler.selectors_with_name(tree, "*")
    assert_equal(1, selectors.size)
#    sel = selectors[0]
#    puts sel.class
#    puts sel.methods
#    puts sel.selector_source_range.start_pos.line
#    puts sel.selector_source_range.start_pos.offset
#    puts sel.selector_source_range.end_pos.line
#    puts sel.selector_source_range.end_pos.offset
#    puts sel.source_range.start_pos.line
#    puts sel.source_range.start_pos.offset
#    puts sel.source_range.end_pos.line
#    puts sel.source_range.end_pos.offset
  end
  
  def test_CssHandler_append_property_in_universal_selector
    engine = CssHandler.to_engine(UNIVERSAL_SEL_CSS)
    prop = {:name => "toto", :value => "tata"}
    css_content = File.open(UNIVERSAL_SEL_CSS, "r").read
    new_css = CssHandler.append_property_in_universal_selector(css_content,
                                                               engine,
                                                               prop)
    modified_css = File.open(UNIVERSAL_SEL_APPEND_CSS, "r").read
    assert_equal(modified_css, new_css) 
  end

  def test_CssHandler_modify_each_property_values_one
    engine = CssHandler.to_engine(UNIVERSAL_SEL_CSS)
    tree = engine.to_tree

    prop = {:name => "-TopinambourTerminal-foreground", :value =>"black"}
    css_content = File.open(UNIVERSAL_SEL_CSS, "r").read
    new_css = CssHandler.modify_each_property_values(css_content,
                                                     engine,
                                                     prop)
    modified_css = File.open(UNIVERSAL_SEL_MOD_CSS, "r").read
    assert_equal(modified_css, new_css) 

  end
  def test_CssHandler_modify_each_property_values_two
    engine = CssHandler.to_engine(MULTIPLE_PROP_CSS)
    tree = engine.to_tree

    prop = {:name => "-TopinambourTerminal-foreground", :value =>"black"}
    css_content = File.open(MULTIPLE_PROP_CSS, "r").read
    new_css = CssHandler.modify_each_property_values(css_content,
                                                     engine,
                                                     prop)
    modified_css = File.open(MULTIPLE_PROP_MOD_CSS, "r").read
    assert_equal(modified_css, new_css) 

  end
end
