require 'opmlreader'

class OpmlReaderTest < Test::Unit::TestCase

  def test_read_folders
    reader = OpmlReader.new("/home/misto/feeds.opml")
    folders = reader.get
    
    assert_equals(folders[0], "Planets")
    assert_equals(folders[1], "News")
    assert_equals(folders[2], "Blogs")
    assert_equals(folders[3], "Wikis")
    assert_equals(folders[4], "Foren")
    assert_equals(folders[5], "Projekte")
    assert_equals(folders[6], "Podcasts")
    assert_equals(folders[7], "Imported Feeds")
    
  end
end