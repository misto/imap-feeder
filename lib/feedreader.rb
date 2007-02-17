require 'rss/0.9'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'
require 'open-uri'

class FeedReader

  def initialize(feed_url)
     open(feed_url) do |url|
      read_content url.read
    end
  end

  def read_content(feed)
    result = RSS::Parser.parse(feed, false)
    @messages = []
    result.items.each do |item|
      @messages << Message.new(:title => item.title, :time => item.pubDate, :body => item.description)
    end
    @messages
  end
  
  def get_newer_than(title)
    new_messages = []
    @messages.each do |message|
      return new_messages if message.title == title
      new_messages << message
    end
  end

end