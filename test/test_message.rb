require 'message'

class MessageTest < Test::Unit::TestCase

  def test_creation
    m = Message.new(:title => "title", :body => "body")
    assert m.title == "title"
    assert m.body  == "body"
  end
  
  def test_creation_title_only
    m = Message.new(:title => "title")
    assert m.title == "title"
    assert m.body  == ""
  end
  
  def test_creation_body_only
    m = Message.new(:body => "body")
    assert m.title == ""
    assert m.body  == "body"
  end
end
