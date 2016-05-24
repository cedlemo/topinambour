# simple Regex builder for the Rgb color names
file = File.open("rgb.txt", "r")

out = File.open("rgb_names_regexes.rb", "w+")

new_lines = []
file.each_line do |line|
  #new_lines << line.gsub(/\A\s*/,"").gsub(/\s*\z/,"").gsub(/\s/, "\\\\s").chomp
  new_lines << line.gsub(/\A\s*/,"").gsub(/\s*\z/,"").chomp
end
out.puts "module RbgNames"
out.puts ("COLOR_NAMES = (" + new_lines.join("|") + ")")
out.puts "end"

file.close
out.close
