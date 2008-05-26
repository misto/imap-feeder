require 'yaml'

require 'imap-feeder/opmlreader'
require 'imap-feeder/messagestore'

class TestingMessageStore < MessageStore
  def initialize(file)
    @file = file
    File.open(@file, "w") do |f|
      YAML.dump({"INBOX.Planets.Planet KDE" => ["Mirko: It works!"],
                 "INBOX.Planets.Planet Gentoo" => [],
                 "INBOX.Blog.Mirko" => []}, f)
    end
    super
  end

  def clean
    File.open(@file, "w").close
  end
end

class TestMessageStore < Test::Unit::TestCase

  FILE_NAME = "#{File.dirname(__FILE__)}/data/last_messages.yaml"

  def setup
    @store = TestingMessageStore.new(FILE_NAME)
  end

  def teardown
    @store.clean
  end

  def test_get_archived
    title = @store.get_archived "INBOX.Planets.Planet KDE"
    assert_equal("Mirko: It works!", title.first)
  end

  def test_add_new
    @store.add_new("INBOX.Planets.Planet KDE", ["Erstes", "Zweites"])
    title = @store.get_archived "INBOX.Planets.Planet KDE"
    assert_equal("Erstes",  title[0])
    assert_equal("Zweites", title[1])
  end
  
  def test_store_and_save
    @store.add_new("INBOX.Planets.Planet KDE", ["FAKE"])
    title = @store.get_archived("INBOX.Planets.Planet KDE")
    @store.save
    saved_store = MessageStore.new(FILE_NAME)
    saved_title = saved_store.get_archived("INBOX.Planets.Planet KDE")
    assert_equal(title, saved_title)
  end
end
