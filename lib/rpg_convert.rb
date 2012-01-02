#!/usr/bin/env ruby

require 'kramdown'
require 'nokogiri'

module RPGConvert

  TEMPLATE_FILE = 'assets/templates/rpg_template.html.kramdown'
  TAG_SEPARATOR = '!'
  CLASS_REGEX = /^\s*CLASS\s*:\s*(.+)\s*$/
  TITLE_REGEX = /^\s*TITLE\s*:\s*(.+)\s*$/
  ABBR_REGEX  = /^\s*ABBR\s*:\s*(.+)\s*$/
  CHARACTER_REGEX = /(org|loc|n?pc)!([a-z]+(_?[a-z]+)?)/

  class << self

    # Handles the interpolation of the transformed Markdown content with
    # the HTML template.
    #
    # @param [String] template The HTML template, passed as a String.
    # @param [String] title    The page's title, which will be displayed
    #                          in the final page's `<head>` and in the
    #                          page's body, as a h1 tag.
    # @param [String] type     The content's type (either a pc, npc, loc
    #                          or org).
    # @param [String] content  The Markdown content.
    # @return [String]         The result of the interpolation
    #
    def inject(template, title, type, content)
      if type == "pc"
        type = "player_character"
      elsif type == "npc"
        type = "player_character"
      end
      template.gsub(/<%=\stype\s%>/, type) \
              .gsub(/<%=\stitle\s%>/, title) \
              .gsub(/<%=\syield\s%>/, custom_markup(title, content))
    end

    # Reformats a set of nodes identified by their class.
    #
    # @param [Nokogiri::HTML::Fragment] doc The converted Markdown
    #                                       document.
    # @param [Nokogiri::XML::Node] column   The column into which the
    #                                       targetted nodes should be
    #                                       transferred.
    # @param [String] node_class  The CSS class of the HTML tags that
    #                             should be reformatted.
    # @param [String] other_class Optional class that should be added to
    #                             the resulting node.
    # @param [String] title       Optional title that should be added as a
    #                             child of the resulting node.
    # @param [Symbol] position    Position of the resulting node, relative
    #                             to the target column.
    #
    def reformat(doc, column, node_class, other_class, title=nil, position=:bottom)
      doc.xpath("*[@class = '#{node_class}']").each do |node|
        node['class'] = ""
        sub_node = node.clone
        new_node = Nokogiri::XML::Node.new("div", doc)
        new_node['class'] = node_class + ' ' + other_class
        new_node.inner_html = "<h2>#{title.nil? ? node['title'] : title}</h2>"
        new_node <<(sub_node)
    
        if position == :bottom
          column << new_node
        else
          column.first_element_child.before(new_node)
        end
        node.remove
      end
    end
    
    # Replaces all references of PCs, NPCs, locations and organisations by
    # an HTML link featuring the actual name of the item.
    #
    # @param [String] markdown The markdown content that should be
    #                          modified.
    # @param [Hash]   abbr_map Hash of link tags with the corresponding
    #                          name.
    # @return [String] The modified Markdown content.
    #
    def create_links(markdown, abbr_map)
      while match = markdown.match(CHARACTER_REGEX)
        markdown.gsub!(match[0], "<a href='...'>#{abbr_map[match[0]]}</a>")
      end
      markdown
    end
    
    # Restructures the HTML content, initially presented as a String.Adds
    # columns and reformats the sidenotes.
    #
    # @param [String] title   The HTML page's title
    # @param [String] content The HTML content
    # @return [Nokogiri::HTML::Fragment] the reformatted HTML document.
    #
    def custom_markup(title, content)
      doc = Nokogiri::HTML.fragment(content)
    
      # Creation of third column
      column = Nokogiri::XML::Node.new("div", doc)
      column['class'] = 'thirdColumn'
    
    
      main = Nokogiri::XML::Node.new("div", doc)
      main['class'] = 'main'
    
      container = Nokogiri::XML::Node.new("div", doc)
    
      if doc.children.first.name == "h1"
        container << doc.children.first
      else
        title_tag = Nokogiri::XML::Node.new("h1", doc)
        title_tag['class'] = 'pageTitle'
        title_tag.inner_html = title
        container << title_tag
      end
    
      doc.children.each {|node| main << node}
    
      container << main
      container << column
    
      reformat(main, column, "leadingIdea", "box", "Leading idea")
      reformat(main, column, "actingDirection", "box", "Acting directions")
      reformat(main, column, "location", "box", "Location description")
      reformat(main, column, "sidenote", "box")
      reformat(main, main, "synopsis", "", "Scene synopsis", :top)
      container.children.to_html
    end

    # Extracts the data corresponding to the regular expression (if any),
    # deletes the whole matched substring from the input content and
    # returns the first matched group.
    #
    # @param [String] content The parsed content
    # @param [Regexp] regex   The regular expression
    # @return [String] The matched content, or nil if none was found
    #
    def extract_regexed_data(content, regex)
      if result = content.match(regex)
        content.gsub!(regex, '')
        result = result[1]
      end
      result
    end

    # Extracts all relevant data from the Markdown input file.
    #
    # @param [String] input_file Path to the input file.
    # @return [Hash]  A Hash of data extracted from the input file.
    #
    def extract_file_data(input_file)
      extension = File.extname(input_file)
      file_name = File.basename(input_file, extension)

      raw_content = File.open(input_file) do |f|
        f.read
      end

      file_class, abbreviation, title = [
        extract_regexed_data(raw_content, CLASS_REGEX),
        extract_regexed_data(raw_content, ABBR_REGEX),
        extract_regexed_data(raw_content, TITLE_REGEX)
      ]

      {
        :file_name    => file_name,
        :extension    => extension,
        :class        => file_class,
        :abbreviation => abbreviation || '',
        :title        => title || '',
        :content      => raw_content
      }
    end


    # Converts all the data previously extracted from the Markdown input
    # file into a HTML file, then writes it down into an the HTML output
    # file.
    #
    # @param [Hash]   data       Hash of data required from the Markdown
    #                            to HTML conversion.
    # @param [String] output_dir Path to the output directory, where the
    #                            resulting file should be written.
    # @param [String] template   The HTML template, presented as a String.
    # @param [Hash]   abbr_map   Map of link tags with the corresponding
    #                            names.
    #
    def convert(data, output_dir, template, abbr_map)
      data[:content] = create_links(data[:content], abbr_map)

      html_content = inject(template, data[:title] || 'Test', data[:class] || '', Kramdown::Document.new(data[:content]).to_html)

      File.open(File.join(output_dir, data[:file_name] + '.html'), 'w') do |f|
        f.write(html_content)
      end
    end


    # Converts a set of Markdown files into HTML files, that are then
    # written into a given output path.
    #
    # @param [Array<String] md_files    Array of Markdown file paths.
    # @param String         output_path Path to the directory where the
    #                                   converted files should be written.
    #
    def convert_all(md_files, output_path)
      template = File.open(TEMPLATE_FILE) do |f|
        f.read
      end

      abbr_map = {}
      files = []
      md_files.each do |file|
        data = extract_file_data(file)
        abbr_map[data[:class] + TAG_SEPARATOR + data[:abbreviation]] = data[:title]
        files << data
      end

      files.each do |file_data|
        convert(file_data, output_path, template, abbr_map)
      end
    end
  end
end
