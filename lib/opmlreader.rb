require 'rexml/document'
require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

class FeedUrl
  attr_accessor :name, :children
  
  def initialize(name)
    @name = name
    @children = []
  end
end

class FeedFolder
  attr_accessor :name, :children
  
  def initialize(name)
    @name = name
    @children = []
  end
  
  def add(child)
    @children << child
  end
end

class OpmlParser 

  attr_reader :root

  def initialize
    @root = FeedFolder.new("/")
    @last_element_was_folder = []
    @folder_stack = []
  end

  include REXML::SAX2Listener

  def start_element(uri, localname, qname, attributes)
    return unless localname == "outline"
  
    if attributes['isOpen'] != nil
    
      @folder_stack.push @root
      folder = FeedFolder.new(attributes['text'])
      @root.add(folder)
      @root = folder
      
      @last_element_was_folder.push true
      
    elsif attributes['xmlUrl'] != nil
      @root.add(FeedUrl.new(attributes['xmlUrl']))
      @last_element_was_folder.push false
    end
  end
  
  def end_element(uri, localname, qname)
    return unless localname == "outline"
    
    if(@last_element_was_folder.pop)
      @root = @folder_stack.pop
    end
  end
end

class OpmlReader
  def initialize(file)
    @doc = file
  end
  
  def get
    parser = REXML::Parsers::SAX2Parser.new(REXML::SourceFactory.create_from(File.new(@doc)))
    listener = OpmlParser.new
    parser.listen(listener)
    parser.parse
    listener.root
  end
end

if __FILE__ == $0

  def print_all element, indent = 0
    puts ' ' * indent + element.name
    element.children.each do |folder|
        print_all(folder, indent + 2) 
    end
  end

  parser = OpmlReader.new("/home/misto/feeds.opml")
  print_all(parser.get)
end