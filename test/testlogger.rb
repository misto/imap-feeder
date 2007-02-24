class TestLogger
  attr_reader :debug_msg, :warn_msg, :error_msg, :info_msg

  def initialize
    @debug_msg = []
    @warn_msg  = []
    @error_msg = []
    @info_msg = []
  end
  def debug(msg)
    @debug_msg << msg
  end
  def warn(msg)
    @warn_msg << msg
  end
  def error(msg)
    @error_msg << msg
  end
  def info(msg)
    @info_msg << msg
  end
end