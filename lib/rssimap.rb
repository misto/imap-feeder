require 'lib/server'
require 'lib/message'
require 'lib/opmlreader'
require 'lib/feedreader'

require 'rss/0.9'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'
require 'open-uri'


$server = Server.new :host => "misto.ch", :user => "rss", :pass => "qaysedc"
root = OpmlReader.get File.new("/home/misto/feeds.opml")

def create_folders(folder, path)

  complete_path = path + folder.name
  puts "Checking #{complete_path}"
  
  unless $server.has_folder? complete_path
    puts "Creating #{complete_path}"
    $server.create_folder complete_path  
  end
  
  if folder.class == FeedUrl
    puts "Folder #{folder} has URLs."
    reader = FeedReader.new(folder.url)  
    latest = $server.get_latest_in(complete_path)
    puts "latest message is #{latest}"
    messages = reader.get_newer_than(latest)
    p messages
    messages[0..10].each do |msg|
      $server.send(msg, complete_path)
      puts "Found new: #{msg.title}"
    end
    return
  end
  
  (folder.children + folder.urls).each do |child|
    create_folders(child, complete_path + '.')
  end  
end

create_folders(root, "INBOX")
