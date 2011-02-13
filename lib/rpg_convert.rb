#!/usr/bin/env ruby

require 'kramdown'
require 'nokogiri'

module RPGConvert

  TEMPLATE_FILE = 'assets/templates/rpg_template.html.kramdown'
  CLASS_REGEX = /^\s*CLASS\s*:\s*(\w+)\s*/
  CHARACTER_REGEX = /(org|loc|n?pc)!([a-z]+(_?[a-z]+)?)/

  def self.inject(template, title, type, content)
    linked_content = create_links(content)

    if type == "pc"
      type = "player_character"
    elsif type == "npc"
      type = "player_character"
    end
    template.gsub(/<%=\stype\s%>/, type) \
            .gsub(/<%=\stitle\s%>/, title) \
            .gsub(/<%=\syield\s%>/, custom_markup(linked_content))
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
  
  
  def self.create_links(markdown)
    markdown.gsub(CHARACTER_REGEX, '<a href="...">\2</a>')
  end
  
  def self.custom_markup(content)
    doc = Nokogiri::HTML.fragment(content)
  
    # Creation of third column
    column = Nokogiri::XML::Node.new("div", doc)
    column['class'] = 'thirdColumn'
  
  
    main = Nokogiri::XML::Node.new("div", doc)
    main['class'] = 'main'
  
    container = Nokogiri::XML::Node.new("div", doc)
  
    if doc.children.first.name == "h1"
      container << doc.children.first
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


  def self.convert(input_file, output_dir)
    template = File.open(TEMPLATE_FILE) do |f|
      f.read
    end

    raw_content = File.open(input_file) do |f|
      f.read
    end

    file_class = raw_content.match(CLASS_REGEX)

    unless file_class.nil?
      raw_content = raw_content.gsub(CLASS_REGEX, '')
      file_class = file_class[1]
    end

    extension = File.extname(input_file)
    file_name = File.basename(input_file, extension)

    html_content = inject(template, "TEST", file_class || '', Kramdown::Document.new(raw_content).to_html)

    File.open(File.join(output_dir, file_name + '.html'), 'w') do |f|
      f.write(html_content)
    end
  end

end
