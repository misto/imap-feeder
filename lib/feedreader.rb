require 'tempfile'
require 'open-uri'
require 'simple-rss'
require 'htmlentities'
require 'iconv'

$KCODE="U"

class SimpleRSS
  def unescape content
    content.gsub(/(<!\[CDATA\[|\]\]>)/,'').strip
  end
end

class FeedReader
  attr_reader :messages
  def initialize(feed_url)
    @feed_url = feed_url
    @feed = SimpleRSS.parse(open(feed_url))
  end

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
    $log.error "IConv reports an IllegalSequence: #{e.message} from 'str'"
    return str
  end

  def get_newer_than(title)
    return [] if not @feed
    if title == ""
      $log.warn "WARNING! title is empty, that should never happen! Aborting this feed.."
      return []
    end

    match = @feed.source.match(/encoding=["'](.*?)["']/)
    @from = (match && match[1])
    if not @from
      $log.warn "No encoding found for #{@feed_url}, defaulting to UTF-8."
      @from = "UTF-8"
    end
    messages = []
    @feed.entries.each do |item|
      if title == HTMLEntities.decode_entities(conv(item.title))
        $log.warn "Already have #{title}."
        break
      end

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
