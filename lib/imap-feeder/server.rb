require 'base64'
require 'net/imap'
require 'imap-feeder/message'

$KCODE="U"

class Server

  def initialize(params)
    @connection = Net::IMAP.new(params[:host], params[:port], params[:use_ssl])
    result = @connection.login(params[:user], params[:pass])
    @format = params[:format]
  end

  def disconnect
    @connection.disconnect if @connection
  end

  def send(message, folder="INBOX")
    @connection.select(folder)

    if @format == :html
      message = message.as_html
    else
      message = message.format
    end

    message.gsub!(/\n/, "\r\n")
    @connection.append(folder, message, nil, Time.now)
  end

  def retrieve(title, folder="INBOX")
    @connection.examine(folder)
    found = @connection.search(["SUBJECT", title]).first
    return if not found

    imap_header = @connection.fetch([found], "BODY[HEADER.FIELDS (SUBJECT)]")
    retr_title = imap_header.first.attr["BODY[HEADER.FIELDS (SUBJECT)]"]
    retr_title.gsub!(/(^Subject: )|[\n\r]/, "")

    Message.new(:title => base64decode(retr_title), :id => found)
  end

  def base64decode(subject)
    encoded = subject[/^=\?utf-8\?b\?(.*?)$/, 1]
    if encoded
      Base64.decode64(encoded)
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
    true
  rescue Net::IMAP::NoResponseError
    false
  end

  def create_folder(folder)
    path = ''
    folder.split('.').each do |part|
      path << part
      @connection.create(path) unless has_folder?(path)
      path << '.'
    end
  end

  def delete_folder(folder)
    #Switch to root so we can delete the folder
    @connection.examine("INBOX")
    @connection.delete(folder)
  end

  def delete(message, folder="INBOX")
    @connection.select(folder)
    @connection.store(message.id, "+FLAGS", [:Deleted])
    @connection.expunge
  end
end
