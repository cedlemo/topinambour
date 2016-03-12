require "sass"
require "gtk3" #to remove 

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
  
  def self.get_universal_selector_content(filename)
    if css_file?(filename) || scss_file?(filename)
      get_universal_selector_content_in_css(filename)
    elsif sass_file?(filename)
    # TODO
    end
  end
end
