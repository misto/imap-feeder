require 'rexml/document'
require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

require 'rssimap/feedfolder'

#
# Defines the characters that cannot be used as part of an IMAP Folder
#
IMAP_CHARS = "\\w:,\\-= "

#
# Parses an OPML File and extracts the folders and urls of the feeds. A 
# tree like structure is built with FoodFolders and FeedUrls as leafes.
#
class OpmlReader

  #
  # Entry point for the parsing process. Takes the filecontent as a string and returns the root element.
  #
  def self.get(file)
    opml = REXML::Document.new(file)
    parse_opml(opml.elements['opml/body'])
  end
  
  private
  
  #
  # Replaces the disallowed characters from the folder name
  #
  def self.replace_bad_chars(name)
    name.gsub(/[^#{IMAP_CHARS}]+/, "_")
  end
  
  #
  # Parses the given node and recursively traverses through the children
  #
  def self.parse_opml(opml_node, folder = FeedFolder.new(""))
    opml_node.elements.each('outline') do |element|
      if element.attributes['isOpen'] != nil
        child_folder = FeedFolder.new(replace_bad_chars(element.attributes['text']))
        folder.add_sub(child_folder)
        parse_opml(element, child_folder)
      else
        folder.add_url(FeedUrl.new(replace_bad_chars(element.attributes['title']), element.attributes['xmlUrl']))
      end 
    end
    folder
  end
end
