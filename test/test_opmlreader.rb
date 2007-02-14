require 'opmlreader'

class OpmlReaderTest < Test::Unit::TestCase
  
  def test_simple
    result = OpmlReader.get( <<-EOF)
<?xml version="1.0" encoding="UTF-8"?>
<opml version="1.0" >
 <head>
  <text></text>
 </head>
 <body>
  <outline isOpen="false" text="Planets">
  </outline>
 </body>
</opml>
EOF
    assert_equal("/", result.name)
    assert_equal("Planets", result[0].name)
  end

end