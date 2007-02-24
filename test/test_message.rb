require 'lib/message'

class MessageTest < Test::Unit::TestCase

  def test_creation
    m = Message.new(:title => "title", :body => "body")
    assert_equal("title", m.title)
    assert_equal("body", m.body)
  end
  
  def test_creation_with_time
    t = Time.now
    m = Message.new(:title => "title", :body => "body", :time => t)
    assert_equal("title", m.title)
    assert_equal("body", m.body)
    assert_equal(t, m.time)
  end
  
  def test_creation_title_only
    m = Message.new(:title => "title")
    assert_equal("title", m.title)
    assert_equal("", m.body)
  end
  
  def test_creation_body_only
    m = Message.new(:body => "body")
    assert_equal("", m.title)
    assert_equal("body", m.body)
  end
  
  def test_creation_name_with_url
    m = Message.new(:from => "Mirko Stocker", :url => "http://www.url.ch")
    assert_equal("Mirko Stocker <http://www.url.ch>", m.from)
  end
  
  def test_format
    t = Time.now
    m = Message.new(:title => "title", :body => "body", :time => t)
    assert_equal(m.format, <<EOF)
Date: #{t}
Subject: title
From: 
Content-Type: text/plain;
  charset=UTF-8;

body
EOF
  end
  
  def test_format_multiline
    t = Time.now
    m = Message.new(:title => "title", :body => "body\nsecond", :time => t)
    assert_equal(m.format, <<EOF)
Date: #{t}
Subject: title
From: 
Content-Type: text/plain;
  charset=UTF-8;

body
second
EOF
  end
  
  def test_format_encoded
    t = Time.now
    m = Message.new(:title => "Alexander H. Færøy: Meeting friends for the first time…", :body => "body\nsecond", :time => t)
    assert_equal(<<-EOF, m.format)
Date: #{t}
Subject: =?UTF-8?Q?Alexander_H=2e_F=c3=a6r=c3=b8y=3a_Meeting_friends_for_the_first_time=e2=80=a6?=
From: 
Content-Type: text/plain;
  charset=UTF-8;

body
second
EOF
  end
end


class MessageFormatterTest < Test::Unit::TestCase

  def create_message body
    Message.new(:body => body)
  end

  #
  # Paragraphs
  #
  def test_one_p
    m = create_message "<p>X</p>"
    assert_equal("X", m.body)
  end
  
  def test_one_p_with_space
    m = create_message "<p >X</p  >"
    assert_equal("X", m.body)
  end
  
  def test_one_p_in_the_middle
    m = create_message "X<p>Y</p>Z"
    assert_equal("X\nY\nZ", m.body)
  end
  
  def test_p_with_spaces
    m = create_message "X<p >Y</p >Z"
    assert_equal("X\nY\nZ", m.body)
  end
  
  def test_mutliple_p
    m = create_message "<p>Y</p><p>Z</p>"
    assert_equal("Y\n\nZ", m.body)
  end
  
  #
  # Linebreak
  #
  def test_br_html
    m = create_message "Y<br>Z"
    assert_equal("Y\nZ", m.body)
  end
  
  def test_br_xhtml
    m = create_message "Y<br/>Z"
    assert_equal("Y\nZ", m.body)
  end
  
  def test_br_with_space
    m = create_message "Y<br />Z"
    assert_equal("Y\nZ", m.body)
  end
  
  #
  # Lines
  #
  def test_multi_lines
    m = create_message "Y<br /><br /><br /><br /><br />Z"
    assert_equal("Y\n\nZ", m.body)
  end    
  
  #
  # Strong
  #
  def test_multi_lines
    m = create_message "<strong >g</strong>"
    assert_equal("*g*", m.body)
  end    
  
  #
  # HTML Entities
  #
  def test_html_entity
    m = create_message "&#8230;"
    assert_equal("…", m.body)
  end  
  
  #
  # URLs
  #
  def test_href
    m = create_message "Kuck mal <a href=\"http://da.da\">hier</a>!"
    assert_equal("Kuck mal hier[1]!\n\n[1] http://da.da", m.body)
  end
  
  def test_href_single_quotes
    m = create_message "Kuck mal <a href='http://da.da'>hier</a>!"
    assert_equal(<<EOS.chomp, m.body)
Kuck mal hier[1]!

[1] http://da.da
EOS
  end
  
  def test_hrefs
    m = create_message "Kuck mal <a href=\"http://da.da\">hier\n</a> und <a  href=\"http://namal.da\">da</a >!"
    assert_equal(<<EOS.chomp, m.body)
Kuck mal hier[1] und da[2]!

[1] http://da.da
[2] http://namal.da
EOS
  end

end
