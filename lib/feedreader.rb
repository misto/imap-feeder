require 'open-uri'
require 'simple-rss'
require 'htmlentities'

$KCODE="U"

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @feed = SimpleRSS.parse(open(feed_url))
  end

  # we only compare some characters to avoid problems 
  # with special chars and different encodings
  def equal(left, right)
    if left and right
      left.gsub(/[^A-Za-z0-9]/, '') == right.gsub(/[^A-Za-z0-9]/, '') 
    else
      false
    end
  end

  def get_newer_than(title)
    return [] if not @feed

    messages = []
    @feed.entries.each do |item|
      break if equal(HTMLEntities.decode_entities(item.title), title)

      messages << Message.new(
        :title => item.title,
        :time => item.published || item.pubDate || item.date_published,
        :body => item.content_encoded || item.content || item.description,
        :from => item.author,
        :url => item.link)
    end
    messages
  end
end
