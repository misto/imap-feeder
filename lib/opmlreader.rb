require 'rexml/document'
require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

FeedUrl = Struct.new(:name, :url)

class FeedFolder
  attr_accessor :name, :children, :urls
    
  def initialize(name)
    @name = name
    @children = []
    @urls = []
  end
  
  def add_sub(child)
    @children << child
  end
  
  def add_url(url)
    @urls << url
  end
  
  def [](index)
    @children[index]
  end
end

class OpmlReader

  def self.replace_bad_chars name
    name.gsub(/[^\w:,\-= ]+/, "_")
  end
  
  def self.parse_opml(opml_node, folder = FeedFolder.new(""))
    opml_node.elements.each('outline') do |el|
      if el.attributes['isOpen'] != nil
        child_folder = FeedFolder.new(replace_bad_chars(el.attributes['text']))
        folder.add_sub(child_folder)
        self.parse_opml(el, child_folder)
      else
        folder.add_url(FeedUrl.new(replace_bad_chars(el.attributes['title']), el.attributes['xmlUrl']))
      end 
    end
    folder
  end
  
  def self.get(file)
    opml = REXML::Document.new(file)
    parse_opml(opml.elements['opml/body'])
  end
end

if __FILE__ == $0
  def print_all element, indent = 0
    puts ' ' * indent + element.name
    element.children.each do |folder|
        print_all(folder, indent + 2) 
        puts folder.urls
    end
  end

  print_all(OpmlReader.get(File.new("/home/misto/feeds.opml")))
end