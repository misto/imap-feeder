require 'server'

class ServerTest < Test::Unit::TestCase
  
  def setup
    @server = nil
  end
  
  def teardown
    @server.disconnect if @server
  end
  
  def test_server_creation
    assert_nothing_thrown do
      @server = Server.new(:host => "misto.ch", :user => "rss", :pass => "")
      assert @server.connected
    end
  end
  
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
end
