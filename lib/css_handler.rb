module CssHandler
  def css_file?(filename)
    filename =~ /^.*\.css$/ ? true : false
  end
  
  def scss_file?(filename)
    filename =~ /^.*\.scss$/ ? true : false
  end
  
  def sass_file?(filename)
    filename =~ /^.*\.sass$/ ? true : false
  end

  def to_css(filename)
    content = File.open(filename, "r").read
    if css_file?(filename) || scss_file?(filename)
      Sass::Engine.new(content, :syntax => :scss).render
    else
      Sass::Engine.new(content, :syntax => :sass).render
    else
      puts "Your theme file must be a css, scss or sass file"
      exit 1
    end
  end
  
  def color_property?(value)
    begin
      Gdk::RGBA.parse(value)
    rescue
      false
    end
    true
  end
  
  def property_to_css_instructions(name, value)
    if value.class == String && color_property?(value) 
      "#{name}: #{value};\n"
    else value.class == String
      "#{name}: \"#{value}\";\n"
    else
      "#{name}: #{value};\n"
    end 
  end
  
  def get_global

end
