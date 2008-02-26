require 'tempfile'
require 'open-uri'
require 'simple-rss'
require 'htmlentities'
require 'iconv'

$KCODE="U"

# Overwrite SimpleRSS::unescape because of an open bug(#10852)
class SimpleRSS
  def unescape(content)
    content.gsub(/(<!\[CDATA\[|\]\]>)/,'').strip
  end
end

class FeedReader
  attr_reader :messages

  def initialize(feed_url)
    @feed_url = feed_url
    @feed = SimpleRSS.parse(open(feed_url))

    @encoding = @feed.source[/encoding=["'](.*?)["']/, 1]
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

    titles ||= []
    if titles.include?("")
      $log.warn "Title is empty, that should never happen! Aborting #{@feed_url}."
      return []
    end

    entries = @feed.entries.sort do |l, r|
      r = time_from(r)
      l = time_from(l)
      r <=> l
    end

    messages = []
    entries.each do |item|

      item_title = HTMLEntities.decode_entities(conv(item.title))
      if titles.include?(item_title)
        $log.info "Already have '#{item.title[0...10]}...', aborting this feed."
        break
      end

      time = time_from(item)
      body = conv(item.content_encoded || item.content ||
                  item.summary || item.description)
      message = Message.new(
        :title => conv(item.title),
        :time => time,
        :body => body,
        :from => conv(item.author),
        :url => conv(item.link)
      )
      messages << message
    end

    messages
  end

  def time_from item
    item.published || item.pubDate || item.date_published || Time.now.gmtime
  end
end
