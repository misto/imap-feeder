require 'lib/feedreader'
require 'lib/message'

class MockFeedReader < FeedReader
  def initialize; end
end

class TestFeedReader < Test::Unit::TestCase
  
  def setup
    @reader = MockFeedReader.new
  end
  
  def test_reading_first_feed
    messages = @reader.read_content(FIRST_FEED)
    
    assert_equal(1, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100"), messages.first.time)
    assert_equal("Mirko Stocker: KDE in Heroes!", messages.first.title)
    assert_equal("24 und Alias", messages.first.body)
  end  
  
  def test_reading_second_feed
    messages = @reader.read_content(SECOND_FEED)
    
    assert_equal(2, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100"), messages[0].time)
    assert_equal("Mirko Stocker: KDE in Heroes!", messages[0].title)
    assert_equal("24 und Alias", messages[0].body)
    
    assert_equal(Time.parse("Monday 12 February 2007 17:09"), messages[1].time)
    assert_equal("Thomas Marti: Highlights 2006 (TV)", messages[1].title)
    assert_equal("Empty", messages[1].body)
  end
  
  def test_get_latest
    messages = @reader.read_content(SECOND_FEED)
    new_messages = @reader.get_newer_than(messages.last.title)
    
    assert_equal(1, new_messages.size)
    assert_equal("Mirko Stocker: KDE in Heroes!", new_messages.first.title)
  end
  
  def test_get_latest_or_all
    messages = @reader.read_content(SECOND_FEED)
    new_messages = @reader.get_newer_than("Mirko Stocker: ")
    
    assert_equal(2, new_messages.size)
    assert_equal("Mirko Stocker: KDE in Heroes!", new_messages.first.title)
    assert_equal("Thomas Marti: Highlights 2006 (TV)", new_messages[1].title)
  end
  
  def test_get_nothing
    messages = @reader.read_content(SECOND_FEED)
    new_messages = @reader.get_newer_than(messages.first.title)
    assert new_messages.empty?
  end
end

FIRST_FEED = <<-EOS
      <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Mirko Stocker: KDE in Heroes!</title>
              <link>http://blog.misto.ch/archives/324</link>
              <description>24 und Alias</description>
              <pubDate>Wed, 15 Feb 2007 00:05 +0100</pubDate>
            </item>
          </channel>
        </rss>
EOS

SECOND_FEED = <<-EOS
      <?xml version="1.0"?>
        <rss version="2.0">
          <channel>
            <item>
              <title>Mirko Stocker: KDE in Heroes!</title>
              <link>http://blog.misto.ch/archives/324</link>
              <description>24 und Alias</description>
              <pubDate>Wed, 15 Feb 2007 00:05 +0100</pubDate>
            </item>
            <item>
              <title>Thomas Marti: Highlights 2006 (TV)</title>
              <link>http://blog.zones.ch/2007_02_12-highlights-2006-tv</link>
              <description>Empty</description>
              <pubDate>Monday 12 February 2007 17:09</pubDate>
            </item>
          </channel>
        </rss>
EOS
