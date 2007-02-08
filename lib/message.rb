class Message

  attr_reader :title, :body, :time

  def initialize(params)
    @title = params[:title] || ""
    @body = params[:body] || ""
    @time = params[:time] || Time.now
  end
  
  def format
    return <<-EOF
Date: #{@time}
Subject: #{@title}
From:
To:

#{@body}
EOF
  end
end
