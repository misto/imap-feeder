require 'base64'
require 'net/imap'
require 'lib/message'

$KCODE="U"

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
  
  def send(message, folder = "INBOX")
    @connection.select folder
    @connection.append(folder, message.format.gsub(/\n/, "\r\n"), nil, Time.now)
  end
  
  def retrieve(title, folder = "INBOX")
    @connection.examine folder
    found = @connection.search(["SUBJECT", title]).first || return

    imap_header = @connection.fetch([found], "BODY[HEADER.FIELDS (SUBJECT)]")
    retr_title = imap_header.first.attr["BODY[HEADER.FIELDS (SUBJECT)]"].gsub(/(^Subject: )|[\n\r]/, "")

    Message.new(:title => base64decode(retr_title), :id => found)
  end
  
  def base64decode subject
    if subject =~ /^=\?utf-8\?b\?(.*?)$/
      Base64.decode64($1)
    else
      subject
    end
  end
  private :base64decode
  
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
  
  def create_folder(folder)
    @connection.create(folder)
  rescue Net::IMAP::NoResponseError
    throw :cannot_create
  end
  
  def delete_folder(folder)
    #Switch to root so we can delete the folder
    @connection.examine("INBOX")
    @connection.delete(folder)
  rescue Net::IMAP::NoResponseError
    throw :cannot_delete
  end
  
  def delete(message, folder = "INBOX")
    @connection.select(folder)
    @connection.store(message.id, "+FLAGS", [:Deleted])
    @connection.expunge
  end
end
