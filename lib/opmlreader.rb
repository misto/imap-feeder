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

class OpmlParser 

  attr_reader :root_element

  def initialize
    @root_element = FeedFolder.new ""
    @last_element_was_folder = []
    @folder_stack = []
  end

  include REXML::SAX2Listener

  def start_element(uri, localname, qname, attributes)
    return unless localname == "outline"
  
    if attributes['isOpen'] != nil
    
      @folder_stack.push @root_element
      folder = FeedFolder.new(attributes['text'].gsub(/[^\w]+/, "_"))
      @root_element.add_sub folder
      @root_element = folder
      
      @last_element_was_folder.push true
      
    elsif attributes['xmlUrl'] != nil
      @root_element.add_url(FeedUrl.new(attributes['title'].gsub(/[^\w]+/, "_"), attributes['xmlUrl']))
      @last_element_was_folder.push false
    end
  end
  
  def end_element(uri, localname, qname)
    return unless localname == "outline"
    
    if(@last_element_was_folder.pop)
      @root_element = @folder_stack.pop
    end
  end
end

class OpmlReader
  def self.get(file)
    parser = REXML::Parsers::SAX2Parser.new(REXML::SourceFactory.create_from(file))
    listener = OpmlParser.new
    parser.listen(listener)
    parser.parse
    listener.root_element
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