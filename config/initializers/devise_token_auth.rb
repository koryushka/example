DeviseTokenAuth.setup do |config|
  config.check_current_password_before_update = :password
  config.change_headers_on_each_request = false
end