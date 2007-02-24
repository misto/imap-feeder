require 'lib/rssimapconfig'

class TestLogger
  attr_reader :debug_msg, :warn_msg, :error_msg

  def initialize
    @debug_msg = []
    @warn_msg  = []
    @error_msg = []
  end
  def debug(msg)
    @debug_msg << msg
  end
  def warn(msg)
    @warn_msg << msg
  end
  def error(msg)
    @error_msg << msg
  end
end

class RssImapConfigTest < Test::Unit::TestCase
  
  OPML_FILE = "#{File.dirname(__FILE__)}/data/simple.opml"
  ERRONEOUS_FILE = "#{File.dirname(__FILE__)}/data/erroneous.yml"
  
  def setup
    $log = TestLogger.new
  end
  
  def test_create
    output = ""
    RssImapConfig.create(File.open(OPML_FILE), output)
    result = YAML.load(output)

    assert_equal("http://planetkde.org/rss20.xml", result.first['feed']['url'])
    assert_equal("INBOX.Planets.Planet KDE", result.first['feed']['path'])
    
    assert_equal("http://planet.gentoo.org/rss20.xml", result.last['feed']['url'])
    assert_equal("INBOX.Planets.Planet Gentoo", result.last['feed']['path'])
    
    assert_equal([], $log.error_msg)
    assert_equal([], $log.warn_msg)
    assert_equal(2, $log.debug_msg.length)
  end
  
  def test_check
    RssImapConfig.check(File.open(ERRONEOUS_FILE))
    p $log
    assert_equal("Invalid character found in 'INBOX.Planets.Planet KDE's': '", $log.error_msg.first)
    assert_equal("Exception while connecting to http://misto.chh: getaddrinfo: Name or service not known.", $log.warn_msg.first)
    assert_equal("Problem connecting to http://misto.ch/invalid.html: Not Found", $log.warn_msg.last)
  end
  
end