require 'imap-feeder/message'
require 'time'

$tidy_path = "/usr/lib/libtidy.so"

class MessageTest < Test::Unit::TestCase

  def test_creation
    m = Message.new(:title => "title", :body => "body")
    assert_equal("title", m.title)
    assert_equal("body", m.body)
  end
  
  def test_creation_with_time
    t = Time.now.localtime
    m = Message.new(:title => "title", :body => "body", :time => t)
    assert_equal("title", m.title)
    assert_equal("body", m.body)
    assert_equal(t.rfc2822, m.time)
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
    assert_equal("Mirko Stocker", m.from)
  end
  
  def test_format_with_plus
    t = Time.parse("Mon, Mar 05 2007 15:24:12 +0100")
    m = Message.new(:title => "C/C++", :body => "body", :time => t)
    assert_equal(<<EOF, m.format)
Date: Mon, 05 Mar 2007 15:24:12 +0100
Subject: C/C++
From: Unknown <spam@example.org>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

body
EOF
  end  

  def test_format
    t = Time.parse("Mon, Mar 05 2007 15:24:12 +0100")
    m = Message.new(:title => "title", :body => "body", :time => t)
    assert_equal(<<EOF, m.format)
Date: Mon, 05 Mar 2007 15:24:12 +0100
Subject: title
From: Unknown <spam@example.org>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

body
EOF
  end  

  def test_format_with_url
    t = Time.parse("Mon, Mar 05 2007 15:26:49 +0100")
    m = Message.new(:title => "title", :body => "body", :time => t, :url => "http://www.misto.ch")
    assert_equal(<<EOF, m.format)
Date: Mon, 05 Mar 2007 15:26:49 +0100
Subject: title
From: Unknown <spam@example.org>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

body

http://www.misto.ch
EOF
  end
  
  def test_format_multiline
    t = Time.parse("Mon, Mar 05 2007 15:26:49 +0100")
    m = Message.new(:title => "title", :body => "<p>body</p>second", :time => t)
    assert_equal(<<EOF, m.format)
Date: Mon, 05 Mar 2007 15:26:49 +0100
Subject: title
From: Unknown <spam@example.org>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

body

second
EOF
  end

  def test_format_encoded
    t = Time.parse("Mon, Mar 05 2007 15:26:16 +0100")
    m = Message.new(:title => "Xæxøx: …", :body => "<p>body</p>second", :time => t)
    assert_equal(<<-EOF, m.format)
Date: Mon, 05 Mar 2007 15:26:16 +0100
Subject: X=?UTF-8?Q?=c3=a6?=x=?UTF-8?Q?=c3=b8?=x: =?UTF-8?Q?=e2=80=a6?=
From: Unknown <spam@example.org>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

body

second
EOF
  end
end

class HtmlMessageTest < Test::Unit::TestCase

  def test_bold_text
    t = Time.parse("Mon, Mar 05 2007 15:26:16 +0100")
    m = Message.new(:title => "something bold", :body => "<strong>body</strong>second", :time => t)
    assert_equal(<<-EOF, m.as_html)
Date: Mon, 05 Mar 2007 15:26:16 +0100
Subject: something bold
From: Unknown <spam@example.org>
Content-Type: text/html;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

<strong>body</strong>second
    EOF
  end

  def test_url
    t = Time.parse("Mon, Mar 05 2007 15:26:16 +0100")
    m = Message.new(:title => "with url", :body => "body", :time => t, :url => "http://url")
    assert_equal(<<-EOF, m.as_html)
Date: Mon, 05 Mar 2007 15:26:16 +0100
Subject: with url
From: Unknown <spam@example.org>
Content-Type: text/html;
  charset="utf-8"
Content-Transfer-Encoding: 8bit

body<br/><br/><a href='http://url'>http://url</a>
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
    assert_equal("X\n\nY\n\nZ", m.body)
  end
  
  def test_p_with_spaces
    m = create_message "X<p >Y</p >Z"
    assert_equal("X\n\nY\n\nZ", m.body)
  end
  
  def test_mutliple_p
    m = create_message "<p>Y</p><p>Z</p>"
    assert_equal("Y\n\nZ", m.body)
  end
  
  def test_font
    m = create_message "<font>Z</font>"
    assert_equal("Z", m.body)
  end
  
  #
  # Linebreak
  #
  def test_br_html
    m = create_message "Y<br>Z"
    assert_equal("Y\n\nZ", m.body)
  end
  
  def test_br_xhtml
    m = create_message "Y<br/>Z"
    assert_equal("Y\n\nZ", m.body)
  end
  
  def test_br_with_space
    m = create_message "Y<br />Z"
    assert_equal("Y\n\nZ", m.body)
  end
  
  #
  # Lines
  #
  def test_multi_lines
    m = create_message "Y<br /><br /><br /><br /><br />Z"
    assert_equal("Y\n\nZ", m.body)
  end    
   
  def test_sanitize_newlines_with_spaces
    m = create_message "<p>aa</p>\n \n\t\n    \n<p>aa</p>"
    assert_equal("aa\n\naa", m.body)
  end

  def test_sanitize_newlines
    m = create_message "<p>aa</p>\n\n\n\n<p>aa</p>"
    assert_equal("aa\n\naa", m.body)
  end
  
  #
  # Italic
  #
  def test_italic
    m = create_message "<i>yeah</i>"
    assert_equal("*yeah*", m.body)
  end
  
  #
  # Strong
  #
  def test_strong
    m = create_message "<strong >g</strong> or <em>s</em>"
    assert_equal("*g* or *s*", m.body)
  end
  
  def test_bold
    m = create_message "<b >g</b >"
    assert_equal("*g*", m.body)
  end
  
  #
  # Images
  #
  def test_img
    m = create_message "Juhu <img src='files/smiley.png' alt=':-)' />."
    assert_equal("Juhu :-).", m.body)
  end
  
  def test_img_without_alt
    m = create_message "Juhu <img src='files/smiley.png'/>."
    assert_equal("Juhu .", m.body)
  end
  
  #
  # HTML Entities
  #
  def test_html_entity
    m = create_message "&#8230;"
    assert_equal("…", m.body)
  end  
  def test_html_escaped
    m = create_message "/lib &amp; /bin"
    assert_equal("/lib & /bin", m.body)
  end  
  
  #
  # Abbreviations
  #
  def test_abbr
    m = create_message '<abbr title="Ruby Development Tool">RDT</abbr>'
    assert_equal("RDT (Ruby Development Tool)", m.body)
  end

  #
  # span
  #
  def test_span
    m = create_message 'Thema <span class="caps">REST</span>'
    assert_equal("Thema REST", m.body)
  end

  #
  # URLs
  #
  def test_href
    m = create_message "Kuck mal <a href=\"http://da.da\">hier</a>!"
    assert_equal("Kuck mal hier[1]!\n\n[1] http://da.da", m.body)
  end

  def test_href_with_equal_content
    m = create_message "Kuck mal <a href=\"http://da.da\">http://da.da</a>!"
    assert_equal("Kuck mal http://da.da!", m.body)
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

  def test_lots_of_hrefs
    str = "<a href=\"http://da.da\">link</a>\n" * 12

    m = create_message str
    assert_equal(<<EOS.chomp, m.body)
link[1] link[2] link[3] link[4] link[5] link[6] link[7] link[8] link[9] link[10] link[11] link[12]

[1]  http://da.da
[2]  http://da.da
[3]  http://da.da
[4]  http://da.da
[5]  http://da.da
[6]  http://da.da
[7]  http://da.da
[8]  http://da.da
[9]  http://da.da
[10] http://da.da
[11] http://da.da
[12] http://da.da
EOS
  end
end
