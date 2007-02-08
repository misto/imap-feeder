require 'server'
require 'message'

class ServerConnectionTest < Test::Unit::TestCase
  
  def test_server_host_not_found
    assert_throws :host_not_found do
      @server = Server.new(:host => "misto.chh")
    end
  end
  
  def test_server_login_failed
    assert_throws :login_failed do
      @server = Server.new(:host => "misto.ch", :user => "rss", :pass => "a")
    end
  end  
  
  def test_server_creation
    assert_nothing_thrown do
      @server = Server.new :host => "misto.ch", :user => "rss", :pass => "qaysedc"
      assert @server.connected
    end
  end
end

class ServerTest < Test::Unit::TestCase
  
  def setup
    @server = Server.new :host => "misto.ch", :user => "rss", :pass => "qaysedc"
  end
  
  def teardown
    @server.disconnect if @server
  end
  
  
  def test_server_send_simple_message
    m = Message.new(:title => "test-message", :body => "body")
    assert @server.send(m, "INBOX")
  end
  
  def test_server_send_simple_message_to_subfolder
    m = Message.new(:title => "test-message2", :body => "body")
    assert @server.send(m, "INBOX.Comics")
    assert ! @server.has?("test-message2", "INBOX")
    assert @server.has?("test-message2", "INBOX.Comics")
  end
  
  def test_server_retrieve_message_header
    m = @server.retrieve("test-message", "inbox")
    assert_equal(m.title, "test-message")
  end
  
  def test_server_retrieve_invalid_message_header
    m = @server.retrieve("test-message invalid", "INBOX")
    assert_nil m
  end
  
  def test_server_has_invalid_message?
    assert ! @server.has?("test-message invalid", "INBOX")
  end
  
  def test_server_has_valid_message?
    assert @server.has?("test-message", "INBOX")
  end
  
  def test_has_folder_inbox?
    assert @server.has_folder?("INBOX")
  end
  
  def test_has_folder_comics?
    assert @server.has_folder?("INBOX.Comics")
  end
  
  def test_has_invalid_folder?
    assert ! @server.has_folder?("InvalidFolder")
  end
end
