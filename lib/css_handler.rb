require "sass"
require "gtk3" # to remove

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

  def self.color_property?(value)
    parsed_color = nil
    begin
      parsed_color = Gdk::RGBA.parse(value)
    rescue
      parsed_color = nil
    end
    parsed_color ? true : false
  end

  def self.property_to_css_instructions(name, value)
    if value.class == String && color_property?(value)
      "#{name}: #{value};\n"
    elsif value.class == String
      "#{name}: \"#{value}\";\n"
    else
      "#{name}: #{value};\n"
    end
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
        return true if prop.name[0] == name
      end
    end
    false
  end

  def self.modify_property(filename, tree, prop)
    # Get the property line/pos via the tree
    # modify the existing prop in the file
    #   create a temp file
    #   copy initial file and modify the part we want
    #   replace initial file with temp file
  end

  def self.append_property_in_universal_selector(filename, tree, prop)
    # Get the universal selector line/pos via the tree
    # append our property at the end of this selector
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
      selectors << node if rule_node_name_is?(node, "*") 
    end
    selectors
  end  
  
  def self.update_css(filename, properties)
    engine = to_engine(filename)
    tree = engine.to_tree
    properties.each do |prop|
      if property_defined?(tree, prop[:name])
        modify_property(filename, tree, prop)
      else
        append_property_in_universal_selector(filename, tree, prop)
      end
    end
  end
end
