require "rake"
require "./lib/about"

Gem::Specification.new do |s|
  s.name        = About::PROGRAM_NAME
  s.version     = About::VERSION
  s.summary     = About::SUMMARY
  s.description = About::COMMENTS
  s.author      = "Cedric LE MOIGNE"
  s.email       = "cedlemo@gmx.com"
  s.homepage    = About::WEBSITE
  s.license     = About::LICENSE
  s.files       = FileList["bin/*", "data/*", "lib/*", "COPYING", "README.md"]
  s.executables << "topinambour"
  s.post_install_message = "Have fun with topinambour"
  s.add_runtime_dependency "vte3", "~> 3.0", ">= 3.1.0"
end
