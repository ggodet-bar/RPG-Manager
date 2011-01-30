#!/usr/bin/env ruby

require 'kramdown'
require 'nokogiri'

TEMPLATE_FILE = 'rpg_template.html.maruku'

def usage
  puts "Usage: rpg_convert.rb <type> <maruku_file>\n\ttype\tscenario, pc or npc"
end

def inject(template, title, type, content)
  template.gsub(/<%=\stype\s%>/, type) \
          .gsub(/<%=\stitle\s%>/, title) \
          .gsub(/<%=\syield\s%>/, custom_markup(content))
end

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

def custom_markup(content)
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
  reformat(main, column, "sidenote", "box")
  reformat(main, main, "synopsis", "", "Scene synopsis", :top)
  container.children.to_html
end

if ARGV.size != 2
  usage
  exit
end

template = File.open(TEMPLATE_FILE) do |f|
  f.read
end

raw_content = File.open(ARGV[1]) do |f|
  f.read
end

extension = File.extname(ARGV[1])
file_name = File.basename(ARGV[1], extension)

html_content = inject(template, "TEST", ARGV[0], Kramdown::Document.new(raw_content).to_html)

File.open(file_name + '.html', 'w') do |f|
  f.write(html_content)
end
