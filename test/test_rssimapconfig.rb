require 'lib/rssimapconfig'
require 'test/testlogger'


class RssImapConfigTest < Test::Unit::TestCase
  
  OPML_FILE = "#{File.dirname(__FILE__)}/data/simple.opml"
  ERRONEOUS_FILE = "#{File.dirname(__FILE__)}/data/erroneous.yml"
  
  def setup
    $log = TestLogger.new
  end
  
  def test_create_with_root
    output = ""
    RssImapConfig.create(OPML_FILE, output, "root")
    result = YAML.load(output)

    assert_equal("root.Planets.Planet KDE", result.first['feed']['path'])
  end
  
  def test_create
    output = ""
    RssImapConfig.create(OPML_FILE, output, "INBOX")
    result = YAML.load(output)

    assert_equal("http://planetkde.org/rss20.xml", result.first['feed']['url'])
    assert_equal("INBOX.Planets.Planet KDE", result.first['feed']['path'])
    
    assert_equal("http://planet.gentoo.org/rss20.xml", result.last['feed']['url'])
    assert_equal("INBOX.Planets.Planet Gentoo", result.last['feed']['path'])
    
    assert($log.error_msg.empty?)
    assert($log.warn_msg.empty?)
    assert_equal(2, $log.debug_msg.length)
  end
  
  def test_check
    RssImapConfig.check(File.open(ERRONEOUS_FILE))

    assert_equal("Invalid character found in 'INBOX.Planets.Planet KDE's': '", $log.error_msg.first)
    assert_equal("Exception while connecting to http://misto.chh: getaddrinfo: Name or service not known.", $log.warn_msg.first)
    assert_equal("Problem connecting to http://misto.ch/invalid.html: Not Found", $log.warn_msg.last)
  end
  
end
