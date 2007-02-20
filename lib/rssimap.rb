require 'lib/server'
require 'lib/message'
require 'lib/opmlreader'
require 'lib/feedreader'
require 'lib/messagestore'
require 'yaml'

$server = Server.new :host => "misto.ch", :user => "rss", :pass => "qaysedc"

root = OpmlReader.get File.new("/home/misto/feeds.opml")
$store = MessageStore.new("processed_feeds.yaml")

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
    latest = $store.get_latest(complete_path)
    puts "latest message is #{latest}"
    messages = reader.get_newer_than(latest)[0..10]
    puts "new messages: #{messages.inspect}"
    unless messages.empty?
      messages.each do |msg|
        $server.send(msg, complete_path)
        puts "Found new: #{msg.title}"
      end
      $store.add_new(complete_path, messages.first.title)
    end
    return
  end
  
  (folder.children + folder.urls).each do |child|
    create_folders(child, complete_path + '.')
  end  
end

create_folders(root, "INBOX")

$store.save