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