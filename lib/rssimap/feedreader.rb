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

  def number_of_entries
    @feed.entries.size
  end

  def get_new(archive)
    return [] if not @feed

    archive ||= []
    if archive.include?("")
      $log.warn "Title is empty, that should never happen! Aborting #{@feed_url}."
      return []
    end

    messages = []
    @feed.entries.each do |item|

      body = conv(item.content_encoded || item.content ||
                  item.summary || item.description)
      message = Message.new(
        :title => conv(item.title),
        :time => time_from(item),
        :body => body,
        :from => conv(item.author),
        :url => conv(item.link)
      )

      item_identifier = message.generate_identifier

      if archive.include? item_identifier
        short_name = message.title[0..30]
        short_name << "…" if message.title.length > 30
        $log.debug "Already have '#{short_name}'."
      else
        messages << message
      end
    end

    messages
  end

  def time_from item
    return nil if not item
    item.published || item.pubDate || item.date_published || item.updated || nil
  end
end
