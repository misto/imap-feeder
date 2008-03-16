require 'rssimap/feedreader'
require 'rssimap/message'

class TestFeedReader < Test::Unit::TestCase
  
  RSS20_ONE_ENTRY    = "#{File.dirname(__FILE__)}/data/rss20_one_entry.xml"
  RSS20_TWO_ENTRIES  = "#{File.dirname(__FILE__)}/data/rss20_two_entries.xml"
  RSS20_WITH_AUTHORS = "#{File.dirname(__FILE__)}/data/rss20_with_authors.xml"
  RSS20_NO_BODY      = "#{File.dirname(__FILE__)}/data/rss20_no_body.xml"
  ENCODED_RSS        = "#{File.dirname(__FILE__)}/data/encoded.rss"
 
  def test_reading_first_feed
    messages = FeedReader.new(RSS20_ONE_ENTRY).get_newer_than []
    assert_equal(1, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100"), messages.first.time)
    assert_equal("title1", messages.first.title)
    assert_equal("description1", messages.first.body)
  end  
  
  def test_reading_second_feed
    messages = FeedReader.new(RSS20_TWO_ENTRIES).get_newer_than []
    assert_equal(2, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100"), messages[0].time)
    assert_equal("title1", messages[0].title)
    assert_equal("description1", messages[0].body)
    
    assert_equal(Time.parse("Monday 12 February 2007 17:09"), messages[1].time)
    assert_equal("title2", messages[1].title)
    assert_equal("description2", messages[1].body)
  end
  
  def test_get_latest
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    messages = reader.get_newer_than []
    new_messages = reader.get_newer_than([messages.last.generate_identifier])
    
    assert_equal(1, new_messages.size)
    assert_equal("title1", new_messages.first.title)
  end
  
  def test_get_latest_or_all
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    new_messages = reader.get_newer_than(["Mirko Stocker: "])
    
    assert_equal(2, new_messages.size)
    assert_equal("title1", new_messages.first.title)
    assert_equal("title2", new_messages[1].title)
  end
  
  def test_get_authors
    messages = FeedReader.new(RSS20_WITH_AUTHORS).get_newer_than []
    assert_equal(2, messages.size)
    assert_equal("MaxMuster", messages.first.from)
    assert_equal("MirkoStocker", messages.last.from)
  end  
  
  def test_no_body
    messages = FeedReader.new(RSS20_NO_BODY).get_newer_than []
    assert_equal(1, messages.size)
    assert_equal("", messages.first.body)
  end
  
  def test_get_nothing
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    msgs = reader.get_newer_than []
    new_messages = reader.get_newer_than(["title1#2bae1a894c89827ed79702362bd5ac0c", "title2#026530e9f2ca7a5b20184025f0b354aa"])
    assert new_messages.empty?
  end
  
  def test_get_all
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    messages = reader.messages
    new_messages = reader.get_newer_than(nil)
    assert_equal(2, new_messages.size)
  end

  def test__content_encoded
    reader = FeedReader.new(ENCODED_RSS)
    messages = reader.messages
    new_messages = reader.get_newer_than(nil)
    assert_equal  "<\"ja!\" >", new_messages.first.body
  end
end
