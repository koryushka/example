class Api::V1::DevicesController < ApiController
  include Swagger::Blocks

  def create
    # accepts devise token (should be sent by iOS app) and store it in database; add devise to Amazon SNS registry
    # call ApiHelper::send()
  end

  def update
    # updates devise in Amazon SNS registry (if it is being required)
  end

  def destroy
    # removes devise from database and from Amazon SNS registry
  end

end