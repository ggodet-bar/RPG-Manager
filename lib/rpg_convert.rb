#!/usr/bin/env ruby

require 'kramdown'
require 'nokogiri'

module RPGConvert

  TEMPLATE_FILE = 'assets/templates/rpg_template.html.kramdown'
  CLASS_REGEX = /^\s*CLASS\s*:\s*(.+)\s*$/
  TITLE_REGEX = /^\s*TITLE\s*:\s*(.+)\s*$/
  ABBR_REGEX  = /^\s*ABBR\s*:\s*(.+)\s*$/
  CHARACTER_REGEX = /(org|loc|n?pc)!([a-z]+(_?[a-z]+)?)/

  def self.inject(template, title, type, content)
    #linked_content = create_links(content)

    if type == "pc"
      type = "player_character"
    elsif type == "npc"
      type = "player_character"
    end
    template.gsub(/<%=\stype\s%>/, type) \
            .gsub(/<%=\stitle\s%>/, title) \
            .gsub(/<%=\syield\s%>/, custom_markup(title, content))
  end

  def self.reformat(doc, column, node_class, other_class, title=nil, position=:bottom)
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
  
  def self.create_links(markdown, abbr_map)
    while match = markdown.match(CHARACTER_REGEX)
      markdown.gsub!(match[0], "<a href='...'>#{abbr_map[match[0]]}</a>")
    end
    markdown
  end
  
  def self.custom_markup(title, content)
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


  def self.extract_file_data(input_file)
    extension = File.extname(input_file)
    file_name = File.basename(input_file, extension)

    raw_content = File.open(input_file) do |f|
      f.read
    end

    file_class = raw_content.match(CLASS_REGEX)

    unless file_class.nil?
      raw_content = raw_content.gsub(CLASS_REGEX, '')
      file_class = file_class[1]
    end

    abbreviation = raw_content.match(ABBR_REGEX)
    unless abbreviation.nil?
      raw_content = raw_content.gsub(ABBR_REGEX, '')
      abbreviation = abbreviation[1]
    end

    title = raw_content.match(TITLE_REGEX)
    unless title.nil?
      raw_content = raw_content.gsub(TITLE_REGEX, '')
      title = title[1]
    end

    {
      :file_name    => file_name,
      :extension    => extension,
      :class        => file_class,
      :abbreviation => abbreviation || '',
      :title        => title || '',
      :content      => raw_content
    }
  end


  def self.convert(data, output_dir, template, abbr_map)
    data[:content] = create_links(data[:content], abbr_map)

    html_content = inject(template, data[:title] || 'Test', data[:class] || '', Kramdown::Document.new(data[:content]).to_html)

    File.open(File.join(output_dir, data[:file_name] + '.html'), 'w') do |f|
      f.write(html_content)
    end
  end


  def self.convert_all(md_files, output_path)
    template = File.open(TEMPLATE_FILE) do |f|
      f.read
    end

    abbr_map = {}
    files = []
    md_files.each do |file|
      data = extract_file_data(file)
      abbr_map[data[:class] + '!' + data[:abbreviation]] = data[:title]
      files << data
    end

    files.each do |file_data|
      convert(file_data, output_path, template, abbr_map)
    end
  end
end
