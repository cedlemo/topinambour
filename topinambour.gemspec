require "rake"

Gem::Specification.new do |s|
  s.name        = "topinambour"
  s.version     = "2.0.1"
  s.summary     = "Ruby-gnome2 Terminal emulator"
  s.description = "Terminal Emulator based on the libs vte3 and gtk3 from the ruby-gnome2 project"
  s.author      = "Cedric LE MOIGNE"
  s.email       = "cedlemo@gmx.com"
  s.homepage    = "https://github.com/cedlemo/topinambour"
  s.license     = "GPL-3.0"
  s.files       = FileList["bin/*", "data/*", "lib/*", "COPYING", "README.md"]
  s.executables << "topinambour"
  s.post_install_message = "Have fun with topinambour"
  s.add_runtime_dependency "vte3", "~> 3.0", ">= 3.1.0"
end
