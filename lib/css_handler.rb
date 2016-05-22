# Copyright 2016 Cédric LE MOIGNE, cedlemo@gmx.com
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

##
# This module contains all the methods needed to read, parse
# and modify css file.
# Sass is used to read, parse and get informations about
# css selectors or properties
# The modifying or addition of css properties are done
# with ruby strings facilities
module CssHandler
  def self.css_file?(filename)
    filename =~ /^.*\.css$/ ? true : false
  end

  def self.scss_file?(filename)
    filename =~ /^.*\.scss$/ ? true : false
  end

  def self.sass_file?(filename)
    filename =~ /^.*\.sass$/ ? true : false
  end

  def self.to_css(filename)
    content = File.open(filename, "r").read
    if css_file?(filename) || scss_file?(filename)
      Sass::Engine.new(content, :syntax => :scss).render
    elsif sass_file?(filename)
      Sass::Engine.new(content, :syntax => :sass).render
    else
      puts "Your theme file must be a css, scss or sass file"
      exit 1
    end
  end

  def self.to_engine(filename)
    content = File.open(filename, "r").read
    if css_file?(filename) || scss_file?(filename)
      Sass::Engine.new(content, :syntax => :scss)
    elsif sass_file?(filename)
      Sass::Engine.new(content, :syntax => :sass)
    else
      puts "Your theme file must be a css, scss or sass file"
      exit 1
    end
  end

  def self.reload_engine(engine, css_content)
    Sass::Engine.new(css_content, :syntax => engine.options[:syntax])
  end

  def self.color_property?(value)
    parsed_color = nil
    begin
      parsed_color = Gdk::RGBA.parse(value)
    rescue
      parsed_color = nil
    end
    parsed_color ? true : false
  end

  def self.value_to_css_value(value)
     if value.class == String && color_property?(value)
      "#{value}"
    elsif value.class == String
      %("#{value}")
    else
      "#{value}"
    end

  end

  def self.property_to_css_instructions(name, value)
    "#{name}: #{value_to_css_value(value)}"
  end

  def self.props_with_name(tree, prop_name)
    props = []
    tree.children.each do |node|
      node.each do |prop|
        next if prop.class != Sass::Tree::PropNode
        name = prop.name[0]
        props << prop if name == prop_name
      end
    end
    props
  end

  def self.prop_position(prop)
    source_range = prop.source_range
    [source_range.start_pos, source_range.end_pos]
  end

  def self.property_defined?(tree, name)
    tree.children.each do |node|
      node.each do |prop|
        next if prop.class != Sass::Tree::PropNode
        next if prop.class == Sass::Tree::CommentNode
        return true if prop.name[0] == name
      end
    end
    false
  end

  def self.modify_in_ranges(line, line_number, start_range, end_range, value)
    if line_number < start_range.line || line_number > end_range.line
      line
    else
      tmp = ""
      if line_number == start_range.line
        tmp += line[0..(start_range.offset - 2)] + value_to_css_value(value)
      end
      tmp += line[(end_range.offset - 1)..-1] if line_number == end_range.line
      tmp
    end
  end

  def self.modify_property_value(file_content, property, value)
    start_range = property.value_source_range.start_pos
    end_range = property.value_source_range.end_pos
    tmp = ""
    line_number = 1
    file_content.each_line do |line|
      tmp += modify_in_ranges(line, line_number, start_range, end_range, value)
      line_number += 1
    end
    tmp
  end

  def self.modify_each_property_values(css_content, engine, prop)
    engine = engine
    tree = engine.to_tree
    props = props_with_name(tree, prop[:name])
    new_css = css_content
    (0..(props.size - 1)).each do |i|
      new_css = modify_property_value(new_css, props[i], prop[:value])
      engine = reload_engine(engine, new_css)
      tree = engine.to_tree
      props = props_with_name(tree, prop[:name])
    end
    new_css
  end

  def self.append_new_property_after_line(line, prop, indent)
    tmp = line.gsub(/\;[^\;]*$/, ";\n")
    new_prop = property_to_css_instructions(prop[:name], prop[:value])
    tmp += (indent + new_prop + (Regexp.last_match(0) || ";\n"))
    tmp
  end

  def self.last_child_which_is_not_comment(selector)
    son = nil
    selector.children.each do |child|
      son = child unless child.class == Sass::Tree::CommentNode
    end
    son
  end

  def self.compute_position_to_append(selector, element)
    indent = last_line = nil
    if element
      indent =  " " * (element.name_source_range.start_pos.offset - 1) || ""
      last_line = element.value_source_range.end_pos.line
    else # If we don 't have any property in selector, use sel offset
      indent =  " " * (selector.source_range.start_pos.offset - 1) || ""
      last_line = selector.source_range.start_pos.line
    end
    [indent, last_line]
  end

  def self.append_property_in_universal_selector(css_content, engine, prop)
    last_selector = selectors_with_name(engine.to_tree, "*").last
    last_prop = last_child_which_is_not_comment(last_selector)
    indent, last_line = compute_position_to_append(last_selector, last_prop)
    tmp = ""
    line_number = 1
    css_content.each_line do |line|
      if last_line == line_number
        tmp += append_new_property_after_line(line, prop, indent)
      else
        tmp += line
      end
      line_number += 1
    end
    tmp
  end

  def self.rule_node_name_is?(node, name)
    if node.rule.include?(name)
      true
    elsif node.parsed_rules.to_s == name
      true
    elsif node.resolved_rules == name
      true
    else
      false
    end
  end

  def self.selectors_with_name(tree, sel_name)
    selectors = []
    tree.children.each do |node|
      next unless node.class == Sass::Tree::RuleNode
      selectors << node if rule_node_name_is?(node, sel_name)
    end
    selectors
  end

  def self.update_css_with_new_property(content, engine, prop)
    if property_defined?(engine.to_tree, prop[:name])
      modify_each_property_values(content, engine, prop)
    else
      append_property_in_universal_selector(content, engine, prop)
    end
  end

  def self.update_css(filename, properties)
    engine = to_engine(filename)
    new_css = nil
    content = File.open(filename, "r").read
    properties.each do |prop|
      new_css = update_css_with_new_property(content, engine, prop)
      engine = reload_engine(engine, new_css)
      content = new_css
    end
    new_css
  end
end
