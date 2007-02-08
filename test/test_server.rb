require 'server'
require 'message'

class ServerTest < Test::Unit::TestCase
  
  def setup
    @server = nil
  end
  
  def teardown
    @server.disconnect if @server
  end
  
  def __test_server_creation
    assert_nothing_thrown do
      create_simple_server
      assert @server.connected
    end
  end
  
  def create_simple_server
    @server = Server.new :host => "misto.ch", :user => "rss", :pass => "qaysedc"
  end
  private :create_simple_server
  
  def __test_server_host_not_found
    assert_throws :host_not_found do
      @server = Server.new(:host => "misto.chh")
    end
  end
    
  def __test_server_login_failed
    assert_throws :login_failed do
      @server = Server.new(:host => "misto.ch", :user => "rss", :pass => "a")
    end
  end  
  
  def test_server_send_simple_message
    create_simple_server
    m = Message.new(:title => "test-message", :body => "body")
    assert @server.send(m, "inbox")
  end
end
