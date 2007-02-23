require 'base64'
require 'action_mailer'

class Message

  include ActionMailer::Quoting

  attr_reader :title, :body, :time, :id, :from

  def initialize(params)
    @title = params[:title] || ""
    @from  = params[:from]  || ""
    @body  = strip_html(params[:body]  || "")
    @id    = params[:id]    || 0
    @time  = params[:time]  || Time.now
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
  
  def strip_html(body)
    #replace <p>
    body.gsub!(/^<\s*p\s*>/, '')
    body.gsub!(/<\s*\/\s*p\s*>$/, '')
    body.gsub!(/<\s*p\s*>|<\s*\/\s*p\s*>/, "\n")
    
    #replace <br>
    body.gsub!(/<\s*br\s*\/?\s*>/, "\n")
    
    #replace <strong>
    body.gsub!(/<\s*\/?\s*strong\s*>/, "*")
    
    #sanitize newlines
    body.gsub!(/\n{3,}/, "\n\n")
    
    urls = []
    body.gsub!(/<a.*?href=\"(.*?)\".*?>(.*?)<\s*\/\s*a\s*>/) do 
      urls << $1
      "#{$2}[#{urls.length}]"
    end
    
    unless urls.empty?
      body << "\n"
      urls.each_with_index do |url, i|
        body << "\n[#{(i+1).to_s}] #{url}"
      end
    end

    body
  end
end
