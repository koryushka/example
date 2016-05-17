class AppException < Exception
  attr_reader :code
  attr_reader :message
  attr_reader :data
  attr_reader :http_status

  def initialize(code, message, data, http_status)
    @code = code
    @message = message
    @data = data
    @http_status = http_status
  end
end