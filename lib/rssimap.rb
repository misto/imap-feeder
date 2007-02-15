require 'lib/server'
require 'lib/message'
require 'lib/opmlreader'

require 'rss/0.9'
require 'rss/1.0'
require 'rss/2.0'
require 'rss/parser'
require 'open-uri'


$server = Server.new :host => "misto.ch", :user => "rss", :pass => "qaysedc"
root = OpmlReader.get File.new("/home/misto/feeds.opml")

def create_folders(folder, path)

  complete_path = path + folder.name

  unless $server.has_folder? complete_path
    #$server.create_folder complete_path  
  end
  
  if folder.class == FeedUrl
    
    open(folder.url) do |http|
      response = http.read
      result = RSS::Parser.parse(response, false)
      m = Message.new(
        :title => result.items.first.title, 
        :time => result.items.first.pubDate, 
        :body => result.items.first.description)
        
      puts result.items.first.title + "sent to " + complete_path
      $server.send(m, complete_path)
    end
    
    return
  end
  
  (folder.children + folder.urls).each do |child|
    create_folders(child, complete_path + '.')
  end  
end

create_folders(root, "INBOX")
