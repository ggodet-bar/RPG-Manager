require 'rake'
require './lib/rpg_convert'

task :default => :convert

desc "Convert all files from the Examples directory"
task :convert

Dir['Examples/*'].each do |path|
  if File.directory?(path)
    sub_directory = path
    convertibles = Dir[File.join sub_directory, '**', '*.md']
    unless convertibles.empty?
      FileUtils.rm_rf File.join(sub_directory, 'html_output')
      FileUtils.mkdir_p File.join(sub_directory, 'html_output', 'css')
      FileUtils.mkdir_p File.join(sub_directory, 'html_output', 'fonts')
      FileUtils.cp Dir['assets/stylesheets/*.css'], File.join(sub_directory, 'html_output', 'css')
      FileUtils.cp Dir['assets/fonts/*'], File.join(sub_directory, 'html_output', 'fonts')
      RPGConvert::convert_all(convertibles, File.join(sub_directory, 'html_output'))
    end
  end
end

