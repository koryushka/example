Rails.application.configure do
  @@sns = Aws::SNS::Client.new(
      region: ENV['AWS_REGION'] || 'us-west-2',
      credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY'], ENV['AWS_SECRET_ACCESS_KEY']),
  )
end