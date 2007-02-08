require 'net/imap'

class Server

  attr_reader :connected

  def initialize(params)
    @connected = false   
    @connection = Net::IMAP.new params[:host] 
    result = @connection.authenticate('LOGIN', params[:user], params[:pass])
  rescue SocketError 
    throw :host_not_found
  rescue Net::IMAP::NoResponseError
    disconnect
    throw :login_failed
  else
    @connected = result.name == "OK"
  end
  
  def disconnect
    @connection.disconnect if @connection
  end
  
  def send(message, folder)
    @connection.append(folder, message.format.gsub(/\n/, "\r\n"), nil, Time.now)
  end
end
