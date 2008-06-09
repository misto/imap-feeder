require 'open-uri'

require 'imap-feeder/imapfeederconfig'
require 'test/testlogger'


class ConfigTest < Test::Unit::TestCase

  OPML_FILE = "#{File.dirname(__FILE__)}/data/simple.opml"
  ERRONEOUS_FILE = "#{File.dirname(__FILE__)}/data/erroneous.yml"
  FEEDS_FILE = "#{Dir.pwd}/feeds.yml"

  def setup
    $log = TestLogger.new
  end

  def test_create_with_root
    ImapFeederConfig.create(OPML_FILE, "root")
    result = YAML.load(open(FEEDS_FILE))
    File.delete FEEDS_FILE

    assert_equal("INBOX.root.Planets.Planet KDE", result.first['feed']['path'])
  end

  def test_create
    ImapFeederConfig.create(OPML_FILE, nil)
    result = YAML.load(open(FEEDS_FILE))
    File.delete FEEDS_FILE

    assert_equal("http://planetkde.org/rss20.xml", result.first['feed']['url'])
    assert_equal("INBOX.Planets.Planet KDE", result.first['feed']['path'])

    assert_equal("http://planet.gentoo.org/rss20.xml", result.last['feed']['url'])
    assert_equal("INBOX.Planets.Planet Gentoo", result.last['feed']['path'])

    assert($log.error_msg.empty?)
    assert($log.warn_msg.empty?)
    assert_equal(2, $log.debug_msg.length)
  end

  def test_check
    ImapFeederConfig.check(File.open(ERRONEOUS_FILE))

    assert_equal("Invalid character found in 'INBOX.Planets.Planet KDE's': '", $log.error_msg.first)
    assert_match(/Exception while connecting to/, $log.warn_msg.first)
    assert_match(/connecting/, $log.warn_msg.last)
  end

end
