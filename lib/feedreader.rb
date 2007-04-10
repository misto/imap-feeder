require 'open-uri'
require 'feed-normalizer'
require 'htmlentities'

$KCODE="U"

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @feed = FeedNormalizer::FeedNormalizer.parse(open(feed_url))
  end

  def dec str
    HTMLEntities.decode_entities(str).strip if str
  end

  # we only compare \w\d characters to avoid problems 
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
      break if equal(dec(item.title), title)

      messages << Message.new(
        :title => dec(item.title),
        :time => item.date_published,
        :body => dec(item.content || item.description),
        :from => dec((item.authors.first || "").split("\n").first),
        :url => item.urls.first)
    end
    messages
  end
end
