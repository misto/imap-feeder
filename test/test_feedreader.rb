require 'lib/feedreader'
require 'lib/message'

#$KCODE="U"

class TestFeedReader < Test::Unit::TestCase
  
  RSS20_ONE_ENTRY    = "#{File.dirname(__FILE__)}/data/rss20_one_entry.xml"
  RSS20_TWO_ENTRIES  = "#{File.dirname(__FILE__)}/data/rss20_two_entries.xml"
  RSS20_WITH_AUTHORS = "#{File.dirname(__FILE__)}/data/rss20_with_authors.xml"
  RSS20_NO_BODY      = "#{File.dirname(__FILE__)}/data/rss20_no_body.xml"
  SHOPBLOGGER        = "#{File.dirname(__FILE__)}/data/shopblogger.rss"
 
  def test_reading_first_feed
    messages = FeedReader.new(RSS20_ONE_ENTRY).get_newer_than ""
    assert_equal(1, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100"), messages.first.time)
    assert_equal("Mirko Stocker: KDE in Heroes!", messages.first.title)
    assert_equal("24 und Alias", messages.first.body)
  end  
  
  def test_reading_second_feed
    messages = FeedReader.new(RSS20_TWO_ENTRIES).get_newer_than ""
    assert_equal(2, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100"), messages[0].time)
    assert_equal("Mirko Stocker: KDE in Heroes!", messages[0].title)
    assert_equal("24 \303\274nd Alias", messages[0].body)
    
    assert_equal(Time.parse("Monday 12 February 2007 17:09"), messages[1].time)
    assert_equal("Thomas Marti: Highlights 2006 (TV)", messages[1].title)
    assert_equal("Empty", messages[1].body)
  end
  
  def test_get_latest
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    messages = reader.get_newer_than ""
    new_messages = reader.get_newer_than(messages.last.title)
    
    assert_equal(1, new_messages.size)
    assert_equal("Mirko Stocker: KDE in Heroes!", new_messages.first.title)
  end
  
  def test_get_latest_or_all
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    new_messages = reader.get_newer_than("Mirko Stocker: ")
    
    assert_equal(2, new_messages.size)
    assert_equal("Mirko Stocker: KDE in Heroes!", new_messages.first.title)
    assert_equal("Thomas Marti: Highlights 2006 (TV)", new_messages[1].title)
  end
  
  def test_get_authors
    messages = FeedReader.new(RSS20_WITH_AUTHORS).get_newer_than ""
    assert_equal(2, messages.size)
    assert_equal("PeterSommerlad", messages.first.from)
    assert_equal("MirkoStocker", messages.last.from)
  end  
  
  def test_no_body
    messages = FeedReader.new(RSS20_NO_BODY).get_newer_than ""
    assert_equal(1, messages.size)
    assert_equal("http://blog.misto.ch/archives/324", messages.first.body)
  end
  
  def test_get_nothing
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    new_messages = reader.get_newer_than("Mirko Stocker: KDE in Heroes!")
    assert new_messages.empty?
  end
  
  def test_get_all
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    messages = reader.messages
    new_messages = reader.get_newer_than(nil)
    assert_equal(2, new_messages.size)
  end

  def test_shopblogger
    reader = FeedReader.new(SHOPBLOGGER)
    messages = reader.messages
    new_messages = reader.get_newer_than(nil)
    assert_match(/^Oldschool\[1\] hat's heute Morgen.*/, new_messages.first.body)
  end
end
