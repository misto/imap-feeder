require 'rexml/document'
require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

require 'lib/feedfolder'

class OpmlReader

  def self.replace_bad_chars(name)
    name.gsub(/[^\w:,\-= ]+/, "_")
  end
  
  def self.parse_opml(opml_node, folder = FeedFolder.new(""))
    opml_node.elements.each('outline') do |element|
      if element.attributes['isOpen'] != nil
        child_folder = FeedFolder.new(replace_bad_chars(element.attributes['text']))
        folder.add_sub(child_folder)
        self.parse_opml(element, child_folder)
      else
        folder.add_url(FeedUrl.new(replace_bad_chars(element.attributes['title']), element.attributes['xmlUrl']))
      end 
    end
    folder
  end
  
  def self.get(file)
    opml = REXML::Document.new(file)
    parse_opml(opml.elements['opml/body'])
  end
end