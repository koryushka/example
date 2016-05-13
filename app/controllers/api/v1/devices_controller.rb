class Api::V1::DevicesController < ApiController
  include Swagger::Blocks

  # TODO: add to swagger_path
  def create
    @device = Device.find_by(device_token: device_params[:device_token])
    if @device
        endpoint_response = delete_endpoint(@device.aws_endpoint_arn)
        @device.destroy if endpoint_response.present? && endpoint_response.http_response.status == 200
    end

    @device = Device.new(device_params)
    return render json: { validation_errors: @device.errors.messages }, status: :bad_request if @device.invalid?
    sns_response = insert_token(@device.device_token)
    if sns_response.present? && sns_response.http_response.status == 200

      Device.where(user_id: current_user.id).each do |device|
        endpoint_response = delete_endpoint(device.aws_endpoint_arn)
        next if endpoint_response.nil? || endpoint_response.http_response.status != 200
        device.destroy
      end
      @device.aws_endpoint_arn = sns_response.endpoint_arn
      raise InternalServerErrorException unless @device.save
    end
    render nothing: true

  end

  # # TODO: add to swagger_path
  # def update
  #
  #   return render json: { errors: [{ message: t('missing_required_parameters'), code: 403 }]}, status: :bad_request unless params[:device_token]
  #
  #   if (params[:device_token] != @device.device_token)
  #     @device.assign_attributes(device_params)
  #     return render json: { validation_errors: @device.errors.messages }, status: :bad_request if @device.invalid?
  #
  #     begin
  #       @sns.delete_endpoint(endpoint_arn: @device.aws_endpoint_arn)
  #     rescue => e
  #       return render json: { errors: [{ message: e.message }] }, status: :bad_request
  #     end
  #
  #     begin
  #       sns_response = insert_token(@device.aws_endpoint_arn)
  #       if sns_response.present? && sns_response.http_response.status == 200
  #
  #         @device.aws_endpoint_arn = sns_response.endpoint_arn
  #         @device.save
  #       end
  #     rescue => e
  #       return render json: { errors: [{ message: e.to_s, code: 400 }]}, status: :bad_request
  #     end
  #
  #     return render nothing: true
  #   end
  #
  #
  #   begin
  #     @sns.set_endpoint_attributes(
  #         endpoint_arn: @device.aws_endpoint_arn,
  #         attributes: { 'Enabled' => 'true'}
  #     )
  #   rescue => e
  #     return render json: { errors: [{message: e.message}] }, status: :bad_request
  #   end
  #
  #   render nothing: true
  # end
  #
  # # TODO: add to swagger_path
  # def destroy
  #   # removes device from database and from Amazon SNS registry
  #   begin
  #     @sns.delete_endpoint(endpoint_arn: @device.aws_endpoint_arn)
  #   rescue => e
  #     return render json: { errors: [{ message: e.message }] }, status: :bad_request
  #   end
  #
  #   @device.destroy
  #
  #   render nothing: true
  # end

private
  def device_params
    params[:user_id] = current_user.id
    params.permit(:user_id,
    :device_token,
    :aws_endpoint_arn)
  end


  # Insert device token to SNS
  def insert_token(device_token)
    ApiHelper::sns
    sns.create_platform_endpoint(
        platform_application_arn: "iOS",
        token: device_token,
    )
  end

  # Remove end_point from SNS
  def delete_endpoint(end_point)
    sns.delete_endpoint(endpoint_arn: end_point)
  end
end