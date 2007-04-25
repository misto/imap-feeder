require 'open-uri'
require 'simple-rss'
require 'htmlentities'
require 'iconv'

$KCODE="U"

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @feed = SimpleRSS.parse(open(feed_url))
  end

  # we only compare some characters to avoid problems 
  # with special chars and different encodings
  def equal(titles, right)
    if right
      titles.each do |left|
        return true if left == right
      end
    end
    false
  end

  def conv(str)
    Iconv.iconv("UTF-8", @from, str).first
  rescue Iconv::IllegalSequence => e
    $log.error "IllegalSequence #{e.message}"
    return str
  end

  def get_newer_than(title)
    return [] if not @feed

    match = @feed.source.match(/encoding="(.*?)"/)
    @from = (match && match[1]) || "UTF-8"

    messages = []
    @feed.entries.each do |item|

      break if title and equal(title, HTMLEntities.decode_entities(conv(item.title)))
      messages << Message.new(
        :title => conv(item.title),
        :time => item.published || item.pubDate || item.date_published,
        :body => conv(item.content_encoded || item.content || item.summary || item.description),
        :from => conv(item.author),
        :url => conv(item.link))
    end
    messages
  end
end
