require 'open-uri'
require 'feed_tools'
require 'htmlentities'

$KCODE="U"

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @feed = FeedTools::Feed.open(feed_url, :entry_sorting_property => "time")
  end

  def dec str
    HTMLEntities.decode_entities(str) if str
  end

  def get_newer_than(title)
    messages = []
    @feed.items.each do |item|
      break if dec(item.title) == title

      messages << Message.new(
        :title => dec(item.title),
        :time => item.published,
        :body => dec(item.description),
        :from => dec(item.author && item.author.name),
        :url => item.link)
    end
    messages
  end
end
