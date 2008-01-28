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
    @feed = SimpleRSS.parse(open(feed_url))

    match = @feed.source.match(/encoding=["'](.*?)["']/)
    @encoding = (match && match[1])
    if not @encoding
      $log.warn "No encoding found for #{feed_url}, defaulting to UTF-8."
      @encoding = "UTF-8"
    end
  end

  def conv(str)
    Iconv.iconv("UTF-8", @encoding, str).first
  rescue Iconv::IllegalSequence => e
    $log.error "IConv reports an IllegalSequence: #{e.message} from #{str}"
    return str
  end

  def get_newer_than(titles)
    return [] if not @feed

    if titles && titles.any? {|title| title  == "" }
      $log.warn "WARNING! title is empty, that should never happen! Aborting this feed.."
      return []
    end

    messages = []
    @feed.entries.each do |item|

      already_processed = titles && titles.any? do |title|
        title == HTMLEntities.decode_entities(conv(item.title))
      end

      if already_processed
        $log.warn "Already have #{item.title}, aborting this feed."
      end

      break if already_processed

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
