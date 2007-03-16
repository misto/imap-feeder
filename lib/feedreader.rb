require 'open-uri'
require 'feed_tools'

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @feed = FeedTools::Feed.open(feed_url, :entry_sorting_property => "time")
  end

  def get_newer_than(title)
    messages = []
    @feed.items.each do |item|
      break if item.title == title
      messages << Message.new(
        :title => item.title,
        :time => item.published,
        :body => item.description,
        :from => item.author && item.author.name,
        :url => item.link)
    end
    messages
  end
end
