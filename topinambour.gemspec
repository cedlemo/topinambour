require "rake"

Gem::Specification.new do |s|
  s.name        = "topinambour"
  s.version     = "1.0.6"
  s.summary     = "Ruby-gnome2 Terminal emulator"
  s.description = "Terminal Emulator based on the libs vte3 and gtk3 from the ruby-gnome2 project"
  s.author      = "Cédric LE MOIGNE"
  s.email       = "cedlemo@gmx.com"
  s.homepage    = "https://github.com/cedlemo/topinambour"
  s.license     = "GPL-3.0"
  s.files       = FileList["bin/*", "data/*", "lib/*", "COPYING", "README.md"]
  s.executables << "topinambour"
  s.post_install_message = "Have fun with topinambour"
  s.add_runtime_dependency "vte3", "~> 3.0", ">= 3.0.7"
  s.add_runtime_dependency "gtksourceview3", "~> 3.0", ">= 3.0.7"
  s.add_runtime_dependency "sass", "~> 3.4", ">= 3.4.18"
end
