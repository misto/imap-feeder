require 'message'

class MessageTest < Test::Unit::TestCase

  def test_creation
    m = Message.new(:title => "title", :body => "body")
    assert m.title == "title"
    assert m.body  == "body"
  end
  
  def test_creation_with_time
    t = Time.now
    m = Message.new(:title => "title", :body => "body", :time => t)
    assert m.title == "title"
    assert m.body  == "body"
    assert m.time  == t
  end
  
  def test_creation_title_only
    m = Message.new(:title => "title")
    assert m.title == "title"
    assert m.body  == "[body]"
  end
  
  def test_creation_body_only
    m = Message.new(:body => "body")
    assert m.title == ""
    assert m.body  == "body"
  end
  
  def test_format
    t = Time.now
    m = Message.new(:title => "title", :body => "body", :time => t)
    assert_equal(m.format, <<EOF)
Date: #{t}
Subject: =?utf-8?b?dGl0bGU=?=
From:
To:

body
EOF
  end
  
  def test_format_multiline
    t = Time.now
    m = Message.new(:title => "title", :body => "body\nsecond", :time => t)
    assert_equal(m.format, <<EOF)
Date: #{t}
Subject: =?utf-8?b?dGl0bGU=?=
From:
To:

body
second
EOF
  end
  
end
