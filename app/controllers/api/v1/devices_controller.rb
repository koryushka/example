class Api::V1::DevicesController < ApiController
  include Swagger::Blocks

  # TODO: add to swagger_path
  def create
    # accepts devise token (should be sent by iOS app) and store it in database; add devise to Amazon SNS registry
    @device = Device.find_by(device_token: device_params[:device_token])
    # delete endpoint from sns id exists
    if @device
      begin
        endpoint_response = delete_endpoint(@device.aws_endpoint_arn)
        @device.destroy if endpoint_response.present? && endpoint_response.http_response.status == 200
      rescue => e
        return render json: { errors: [{message: e.to_s, code: 401}] }, status: :bad_request
      end
    end
    # create new device
    @device = Device.new(device_params)
    return render json: { validation_errors: @device.errors.messages }, status: :bad_request if @device.invalid?
    begin
      # TODO:
      sns_response = insert_token(@device.device_token)
      if sns_response.present? && sns_response.http_response.status == 200
        # remove old device from database for current user
        Device.where(user_id: current_user.id).each do |device|
          endpoint_response = delete_endpoint(device.aws_endpoint_arn)
          next if endpoint_response.nil? || endpoint_response.http_response.status != 200
          device.destroy
        end
        # save new aws_endpoint_arn
        @device.aws_endpoint_arn = sns_response.endpoint_arn
        @device.save
      end

      render nothing: true
    rescue => e
      render json: { errors: [{ message: e.to_s, code: 400 }] }, status: :bad_request
    end
  end

  # TODO: add to swagger_path
  def update
    # updates devise in Amazon SNS registry (if it is being required)
  end

  # TODO: add to swagger_path
  def destroy
    # removes devise from database and from Amazon SNS registry
  end

private
  def device_params
    params[:user_id] = current_user.id
    params.permit(:user_id,
    :device_token,
    :aws_endpoint_arn)
  end

  # Find device by id
  def find_device
    device_id = current_user.device
    @device = Device.find_by(id: device_id)

    render json: { errors: [{ message: t('could_not_find_device'), code: 404 }] }, status: :not_found if @device.nil?
  end

  # Insert device token to SNS
  def insert_token(device_token)
    @sns.create_platform_endpoint(
        platform_application_arn: "iOS",
        token: device_token,
        custom_user_data: current_user.email
    )
  end

  # Remove end_point from SNS
  def delete_endpoint(end_point)
    @sns.delete_endpoint(endpoint_arn: end_point)
  end
end