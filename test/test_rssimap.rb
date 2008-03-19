require 'tempfile'
require 'rssimap'
require 'test/testlogger'

class TestServer
  attr_reader :sent

  def initialize
    @sent = []
  end

  def has_folder?(folder)
    true
  end

  def create_folder(folder)
  end

  def send(msg, complete_path)
    @sent << [msg, complete_path]
  end
end

class TestRssImap < Test::Unit::TestCase

  TEST_FEEDS = "#{File.dirname(__FILE__)}/data"

  def setup
    $log = TestLogger.new
    @server = TestServer.new
    @store = MessageStore.new(Tempfile.new("message_store_temp").path)
  end

  def title(index)
    @server.sent[index].first.title
  end

  def body(index)
    @server.sent[index].first.body
  end

  def folder(index)
    @server.sent[index].last
  end

  def test_simple_rss20
    config = <<EOS
- feed:
    url: "#{TEST_FEEDS}/rss20_two_entries.xml"
    path: INBOX.TestFolder
EOS

    RssImap.new(@server, @store, config).run
    assert_equal("Started", $log.info_msg[0])
    assert_equal("Processing INBOX.TestFolder", $log.info_msg[1])

    assert_equal(2, @server.sent.length)
    assert_equal("INBOX.TestFolder", folder(0))
    assert_equal("description1", body(0))
    assert_equal("title1", title(0))
    assert_equal("INBOX.TestFolder", folder(1))
    assert_equal("description2", body(1))
    assert_equal("title2", title(1))

  end
end
