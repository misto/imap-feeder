require 'opmlreader'

class OpmlReaderTest < Test::Unit::TestCase
  
  def test_simple_without_urls
    result = OpmlReader.get(<<-EOF)
      <?xml version="1.0" encoding="UTF-8"?>
      <opml version="1.0" >
       <body>
        <outline isOpen="false" text="Planets">
        </outline>
       </body>
      </opml>
    EOF
    assert_equal("", result.name)
    assert_equal("Planets", result[0].name)
  end    
  
  def test_character_conversion
    result = OpmlReader.get(<<-EOF)
      <?xml version="1.0" encoding="UTF-8"?>
      <opml version="1.0" >
       <body>
        <outline isOpen="false" text="Mirko.Stocker's">
        </outline>
       </body>
      </opml>
    EOF
    assert_equal("", result.name)
    assert_equal("Mirko_Stocker_s", result[0].name)
  end  
  
  def test_simple_one_category
    result = OpmlReader.get(<<-EOF)
      <?xml version="1.0" encoding="UTF-8"?>
      <opml version="1.0" >
       <body>
        <outline isOpen="false" text="Planets">
          <outline title="Planet KDE" xmlUrl="http://planetkde.org/rss20.xml"/>
          <outline xmlUrl="http://planet.gentoo.org/rss20.xml" title="Planet Gentoo"/>
        </outline>
       </body>
      </opml>
    EOF
    assert_equal("", result.name)
    assert_equal("Planets", result[0].name)
    assert_equal("Planet KDE", result[0].urls[0].name)
    assert_equal("http://planetkde.org/rss20.xml", result[0].urls[0].url)
    assert_equal("Planet Gentoo", result[0].urls[1].name)
    assert_equal("http://planet.gentoo.org/rss20.xml", result[0].urls[1].url)
  end
  
  
  def test_simple_category_with_sub
    result = OpmlReader.get(<<-EOF)
      <?xml version="1.0" encoding="UTF-8"?>
      <opml version="1.0" >
       <body>
        <outline isOpen="false" text="Planets">
          <outline isOpen="false" text="Satelites">
            <outline title="The Satelite" xmlUrl="http://misto.ch"/>
          </outline>
        </outline>
       </body>
      </opml>
    EOF
    assert_equal("", result.name)
    assert_equal("Planets", result[0].name)
    assert_equal("Satelites", result[0].children[0].name)
    assert_equal("The Satelite", result[0].children[0].urls[0].name)
    assert_equal("http://misto.ch", result[0].children[0].urls[0].url)
  end
end