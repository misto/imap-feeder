require 'lib/rssimap'
require 'test/testlogger'

$KCODE="U"

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

  def assert_has_messages(*messages) 
    messages.each_with_index do |msg, index|
      assert_equal(msg, @server.sent[index].first.body)
    end
  end
  
  def test_rssimap
    config = <<EOS
- feed:
    url: "#{File.dirname(__FILE__)}/data/rss20_two_entries.xml"
    path: INBOX.TestFolder 
EOS

    RssImap.new(@server, @store, config).run
    assert_equal("Checking INBOX.TestFolder", $log.debug_msg[0])
    #assert_equal("last message was ", $log.debug_msg[1])
    #assert_equal("2 new messages", $log.debug_msg[2])
    
    assert_equal(2, @server.sent.length)
    assert_equal("INBOX.TestFolder", @server.sent.first.last)
    assert_equal("INBOX.TestFolder", @server.sent.last.last)
    assert_has_messages("24 ünd Alias", "Empty")

  end
end
