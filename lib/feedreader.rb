require 'open-uri'
require 'feed_tools'

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @messages = []
    read_content(feed_url)
  end

  def read_content(url)
    feed = FeedTools::Feed.open(url)
    feed.items.each do |item|
      @messages << Message.new(
        :title => item.title, 
        :time => item.published, 
        :body => item.description,
        :from => item.author && item.author.name)
    end
  end
  
  def get_newer_than(title)
    new_messages = []
    @messages.each do |message|
      return new_messages if message.title == title
      new_messages << message
    end
  end
end
