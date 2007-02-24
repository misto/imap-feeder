require 'lib/rssimap'
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

  STORE = "#{File.dirname(__FILE__)}/data/messagestore.yaml"

  def setup
    $log = TestLogger.new
    @server = TestServer.new
    @store = MessageStore.new(STORE)
  end
  
  def teardown
    File.open(STORE, "w").close
  end
  
  def test_rssimap
    config = <<EOS
- feed:
    url: "#{File.dirname(__FILE__)}/data/rss20_two_entries.xml"
    path: INBOX.TestFolder 
EOS

    RssImap.new(@server, @store, config).run
    assert_equal("Checking INBOX.TestFolder", $log.debug_msg[0])
    assert_equal("last message was ", $log.debug_msg[1])
    assert_equal("2 new messages", $log.debug_msg[2])
    
    assert_equal(2, @server.sent.length)
    assert_equal("24 und Alias", @server.sent.first.first.body)
    assert_equal("INBOX.TestFolder", @server.sent.first.last)
    assert_equal("Empty", @server.sent.last.first.body)
    assert_equal("INBOX.TestFolder", @server.sent.last.last)

  end
end
