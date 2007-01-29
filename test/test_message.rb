require 'test/unit'

class MessageTest < Test::Unit::TestCase
  def test_creation
    m = Message.new(:title => "title", :body => "body")
    assert m.title == "title"
    assert m.body  == "body"
  end
end
