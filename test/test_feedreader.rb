require 'rssimap/feedreader'
require 'rssimap/message'

class TestFeedReader < Test::Unit::TestCase
  
  RSS20_ONE_ENTRY    = "#{File.dirname(__FILE__)}/data/rss20_one_entry.xml"
  RSS20_TWO_ENTRIES  = "#{File.dirname(__FILE__)}/data/rss20_two_entries.xml"
  RSS20_WITH_AUTHORS = "#{File.dirname(__FILE__)}/data/rss20_with_authors.xml"
  RSS20_NO_BODY      = "#{File.dirname(__FILE__)}/data/rss20_no_body.xml"
  ENCODED_RSS        = "#{File.dirname(__FILE__)}/data/encoded.rss"
 
  def test_reading_first_feed
    messages = FeedReader.new(RSS20_ONE_ENTRY).get_new []
    assert_equal(1, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100").rfc2822, messages.first.time)
    assert_equal("title1", messages.first.title)
    assert_equal("description1", messages.first.body)
  end  

  def test_size_one
    assert_equal(1, FeedReader.new(RSS20_ONE_ENTRY).number_of_entries)
  end

  def test_size_two
    assert_equal(2, FeedReader.new(RSS20_TWO_ENTRIES).number_of_entries)
  end
  
  def test_reading_second_feed
    messages = FeedReader.new(RSS20_TWO_ENTRIES).get_new []
    assert_equal(2, messages.size)
    assert_equal(Time.parse("Wed, 15 Feb 2007 00:05 +0100").rfc2822, messages[0].time)
    assert_equal("title1", messages[0].title)
    assert_equal("description1", messages[0].body)
    
    assert_equal(Time.parse("Monday 12 February 2007 17:09").rfc2822, messages[1].time)
    assert_equal("title2", messages[1].title)
    assert_equal("description2", messages[1].body)
  end
  
  def test_get_latest
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    messages = reader.get_new []
    new_messages = reader.get_new([messages.last.generate_identifier])
    
    assert_equal(1, new_messages.size)
    assert_equal("title1", new_messages.first.title)
  end
  
  def test_get_latest_or_all
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    new_messages = reader.get_new(["Mirko Stocker: "])
    
    assert_equal(2, new_messages.size)
    assert_equal("title1", new_messages.first.title)
    assert_equal("title2", new_messages[1].title)
  end
  
  def test_get_authors
    messages = FeedReader.new(RSS20_WITH_AUTHORS).get_new []
    assert_equal(2, messages.size)
    assert_equal("MaxMuster", messages.first.from)
    assert_equal("MirkoStocker", messages.last.from)
  end  
  
  def test_no_body
    messages = FeedReader.new(RSS20_NO_BODY).get_new []
    assert_equal(1, messages.size)
    assert_equal("", messages.first.body)
  end
  
  def test_get_nothing
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    msgs = reader.get_new []
    identifiers = msgs.map {|msg| msg.generate_identifier}
    new_messages = reader.get_new(identifiers)
    assert new_messages.empty?
  end
  
  def test_get_all
    reader = FeedReader.new(RSS20_TWO_ENTRIES)
    messages = reader.messages
    new_messages = reader.get_new(nil)
    assert_equal(2, new_messages.size)
  end

  def test__content_encoded
    reader = FeedReader.new(ENCODED_RSS)
    messages = reader.messages
    new_messages = reader.get_new(nil)
    assert_equal  "<\"ja!\" >", new_messages.first.body
  end
end
