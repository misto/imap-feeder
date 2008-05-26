class FakeServer

  attr_reader :connected

  def initialize(params)
    puts "Would connect to #{params[:host]}:#{params[:port]}, with ssl? #{params[:use_ssl]}"
    puts "Would login with #{params[:user]}/#{params[:pass]}"
  end

  def disconnect
  end

  def send(message, folder="INBOX")
    puts "Send message to folder #{folder}: #{message.title}"
  end

  def create_folder(folder)
  end

  def has_folder?(folder)
    true
  end
end
