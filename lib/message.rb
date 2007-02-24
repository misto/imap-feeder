require 'base64'
require 'action_mailer'
require 'hpricot'
require 'htmlentities'

class Message

  include ActionMailer::Quoting

  attr_reader :title, :body, :time, :id, :from

  def initialize(params)
    @title = params[:title] || ""
    @from  = params[:from]  || ""
    @body  = strip_html(params[:body]  || params[:url] || "")
    @id    = params[:id]    || 0
    @time  = params[:time]  || Time.now
    @from << " <#{params[:url]}>" if params[:url]
  end
  
  def format
    return <<-EOF
Date: #{@time}
Subject: #{quote_if_necessary(@title, "UTF-8")}
From: #{quote_if_necessary(@from, "UTF-8")}
Content-Type: text/plain;
  charset=UTF-8;

#{@body}
EOF
  end
  
  private
  
  def replace(doc, element)
    doc.search(element) {|found| found.swap(yield(found)) }
  end
  
  def strip_html(body)
       
    doc = Hpricot(body)
    
    replace(doc, 'p')      {|paragraph| "\n#{paragraph.innerHTML}\n"}
    replace(doc, 'strong') {|strong| "*#{strong.innerHTML}*"}
    replace(doc, 'br')     {|br| "\n"}

    urls = gather_urls(doc)

    body = doc.to_html
         
    unless urls.empty?
      body << "\n"
      urls.each_with_index do |url, i|
        body << "\n[#{i + 1}] #{url}"
      end
    end

    #sanitize newlines
    body.gsub!(/\n{3,}/, "\n\n")
    
    HTMLEntities.decode_entities(body.reverse.chomp.reverse.chomp)
  end
  
  def gather_urls doc
    urls = []
    doc.search('a') do |link|
      href = URI link.attributes['href'] rescue nil
      next unless href && href.host
      urls << href
      link.swap link.innerHTML.reverse.chomp.reverse.chomp + "[#{urls.length}]"
    end
    urls
  end
  
end
