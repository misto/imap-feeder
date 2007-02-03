require 'net/imap'

class Server

  attr_reader :connected

  def initialize(params)

    @connected = false
      
    begin 
      @connection = Net::IMAP.new params[:host] 
      result = @connection.authenticate('LOGIN', params[:user], params[:pass])
    rescue SocketError 
      throw :host_not_found
    rescue Net::IMAP::NoResponseError
      throw :login_failed
    else
      @connected = result.name == "OK"
    end
    
  end
  
  def disconnect
    @connection.disconnect
  end
  
end
