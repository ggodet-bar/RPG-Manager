require 'thor'
require 'rpg_convert'

class RPG < Thor
  include Thor::Actions

  INSTALL_DIR = File.join(File.dirname(__FILE__), '..', '..')

  desc 'convert [PATH]', 'Converts all the contents of PATH into an html RPG booklet'
  def convert(target_path='.')
    unless File.exists?(target_path)
      say "Invalid path", :red
      exit
    end


    if File.directory?(target_path)
      sub_directory = File.expand_path(target_path)

      self.destination_root=sub_directory
      RPG.source_root(INSTALL_DIR)

      convertibles = Dir[File.join sub_directory, '**', '*.md']
      unless convertibles.empty?
        if File.exists?(File.join(destination_root, 'html_output'))
          say 'Cleaning output directory'
          inside('html_output') do |output_dir|
            Dir[File.join(output_dir, '**', '*')].each{|f| remove_file(f, :verbose => false)}
          end
        end

        directory 'assets', 'html_output'

        say 'Launching conversion'
        RPGConvert::convert_all(INSTALL_DIR, convertibles, File.join(sub_directory, 'html_output'))
        say 'Done.'
      end
    end

  end

end
