require "fileutils"

CURRENT_PATH = File.expand_path(File.dirname(__FILE__))
DATA_PATH = "#{CURRENT_PATH}/data"
gresource_bin = "#{DATA_PATH}/topinambour.gresource"
gresource_xml = "#{DATA_PATH}/topinambour.gresource.xml"

task :gen_gresource_bin do
system("glib-compile-resources",
       "--target", gresource_bin,
       "--sourcedir", File.dirname(gresource_xml),
       gresource_xml)
end

task :gen_gschemas_bin do
system("glib-compile-schemas",
       "--targetdir=#{DATA_PATH}",
       DATA_PATH)
end
