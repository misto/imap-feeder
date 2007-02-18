require 'server'
require 'message'

class ServerConnectionTest# < Test::Unit::TestCase
  
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
    assert @server.has?("test-message", "INBOX")
    m = @server.retrieve("test-message", "INBOX")
    assert_equal(m.title, "test-message")
  ensure
    @server.delete(m, "INBOX")
  end
  
  def test_server_send_simple_message_to_subfolder
    @server.create_folder "INBOX.test-folder"
    
    m = Message.new(:title => "test-message2", :body => "body")
    assert @server.send(m, "INBOX.test-folder")
    assert ! @server.has?("test-message2", "INBOX")
    assert @server.has?("test-message2", "INBOX.test-folder")
  ensure
    @server.delete_folder "INBOX.test-folder"
  end
  
  def test_server_retrieve_invalid_message_header
    m = @server.retrieve("test-message invalid", "INBOX")
    assert_nil m
  end
  
  def test_server_has_invalid_message?
    assert ! @server.has?("test-message invalid", "INBOX")
  end
  
  def test_has_folder_inbox?
    assert @server.has_folder?("INBOX")
  end
  
  def test_has_invalid_folder?
    assert ! @server.has_folder?("InvalidFolder")
  end
  
  def test_delete_not_existing
    assert_throws :cannot_delete do
      @server.delete_folder "Inbox.not-existing-folder"
    end
  end
  
  def test_create_already_existing
    @server.create_folder "INBOX.test_dir"
    assert_throws :cannot_create do
      @server.create_folder "INBOX.test_dir"
    end
  ensure
    @server.delete_folder "Inbox.test_dir"
  end
  
  def test_create_and_delete_folder
    assert_nothing_thrown { @server.create_folder "INBOX.test_dir" }
    assert @server.has_folder?("INBOX.test_dir")
    assert_nothing_thrown { @server.delete_folder "INBOX.test_dir" }
    assert ! @server.has_folder?("INBOX.test_dir")
  end

  def test_get_single
    @server.send(Message.new(:title => "title", :body => "body"))
    assert_equal("title", @server.get_latest_in)
  ensure
    @server.delete(@server.retrieve("title"))
  end
  
  def test_get_latest_of_two
    @server.send(Message.new(:title => "title", :body => "body"))
    @server.send(Message.new(:title => "title2", :body => "body"))
    assert_equal("title", @server.get_latest_in)
  ensure
    @server.delete(@server.retrieve("title"))
    @server.delete(@server.retrieve("title2"))
  end
  
  def test_get_latest_with_subfolder
    @server.send(Message.new(:title => "title", :body => "body"))
    @server.create_folder "INBOX.test"
    @server.send(Message.new(:title => "title2", :body => "body"), "INBOX.test")
    
    assert_equal("title", @server.get_latest_in)
  ensure
    @server.delete(@server.retrieve("title"))
    @server.delete(@server.retrieve("title2", "INBOX.test"), "INBOX.test")
    @server.delete_folder "INBOX.test"
  end
  
  def test_latest_from_nothing
    @server.create_folder "INBOX.empty_folder"
    assert_equal([], @server.get_latest_in("INBOX.empty_folder"))
  ensure
    @server.delete_folder "INBOX.empty_folder"
  end

end
