require 'rake'
require './lib/rpg_convert'

task :default => :convert

desc "Convert all files from the Examples directory"
task :convert

Dir['Examples/*'].each do |path|
  if File.directory?(path)
    sub_directory = path
    convertible = Dir[File.join sub_directory, '**', '*.md']
    unless convertible.empty?
      FileUtils.rm_r File.join(sub_directory, 'html_output')
      FileUtils.mkdir_p File.join(sub_directory, 'html_output', 'css')
      FileUtils.cp Dir['assets/stylesheets/*.css'], File.join(sub_directory, 'html_output', 'css')
      convertible.each do |md_path|
        puts "Converting: " + md_path
        RPGConvert::convert(md_path, File.join(sub_directory, 'html_output'))
      end
    end
  end
end

