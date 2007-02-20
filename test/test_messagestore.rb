require 'opmlreader'
require 'messagestore'
require 'yaml'

class MockMessageStore < MessageStore
  def initialize(file)
    @file = file
    File.open(@file,  "w+") do |f|
      YAML.dump({"INBOX.Planets.Planet KDE" => "Boudewijn Rempt (boud): New toy!", 
                 "INBOX.Planets.Planet Gentoo" => "", 
                 "INBOX.Blog.Mirko" => ""}, f)
    end
    super
  end
end

class TestMessageStore < Test::Unit::TestCase

  FILE_NAME = "test_temp_store.yaml"

  def setup
    @store = MockMessageStore.new(FILE_NAME)
  end
  
  def teardown
    #`rm "test_temp_store.yaml"`
  end

  def test_get_latest
    title = @store.get_latest "INBOX.Planets.Planet KDE"
    assert_equal("Boudewijn Rempt (boud): New toy!", title)
  end

  def test_add_new
    @store.add_new("INBOX.Planets.Planet KDE", "Mirko Stocker: RssImap")
    title = @store.get_latest "INBOX.Planets.Planet KDE"
    assert_equal("Mirko Stocker: RssImap", title)
  end
  
  def test_store_and_save
    @store.add_new("INBOX.Planets.Planet KDE", "FAKE")
    title = @store.get_latest("INBOX.Planets.Planet KDE")
    @store.save
    saved_store = MessageStore.new(FILE_NAME)
    saved_title = saved_store.get_latest("INBOX.Planets.Planet KDE")
    assert_equal(title, saved_title)
  end
end