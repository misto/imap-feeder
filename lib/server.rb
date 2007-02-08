require 'net/imap'
require 'message'

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
  
  def retrieve(title, folder)
    @connection.examine folder
    found = @connection.search(["SUBJECT", title]).first || return
    
    imap_header = @connection.fetch([found], "BODY[HEADER.FIELDS (SUBJECT)]")
    retr_title = imap_header.first.attr["BODY[HEADER.FIELDS (SUBJECT)]"].gsub(/(^Subject: )|[\n\r]/, "")
    
    Message.new(:title => retr_title)
  end
  
  def has?(title, folder)
    retrieve(title, folder) != nil
  end  
  
  def has_folder?(folder)
    @connection.examine(folder)
  rescue Net::IMAP::NoResponseError
    false
  else 
    true
  end
end
