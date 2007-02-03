class Message

  attr_reader :title, :body

  def initialize(params)
    @title = params[:title] || ""
    @body = params[:body] || ""
  end
end
