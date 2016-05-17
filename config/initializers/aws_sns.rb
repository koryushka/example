Rails.application.configure do
  @sns = Aws::SNS::Client.new(
      region: ENV['AWS_REGION'] || 'us-west-2',
      access_key_id: ENV['AWS_ACCESS_KEY'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  )
end