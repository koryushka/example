class Api::V1::DevicesController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:create]

  # swagger_path :Devices
  swagger_path '/devices' do
    operation :post do
      key :summary, 'Create device'
      key :description, 'Creates new device'
      parameter do
        key :name, 'device'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :DeviceInput
        end
      end
      # responses
      response 201 do
        key :description, 'Created'
        schema do
          key :'$ref', :Device
        end
      end # end response 201
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end # end response 400
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Devices']
    end # end operation post
  end # end swagger_path :Devices
  def create
    @device = Device.find_by(device_token: device_params[:device_token])
    # Check if device is exists
    if @device
      # Delete if exists
        endpoint_response = delete_endpoint(@device.aws_endpoint_arn)
        if endpoint_response.present? && endpoint_response.http_response.status == 200
          raise InternalServerErrorException unless @device.destroy
        end
    end

    @device = Device.new(device_params)

    sns_response = insert_token(@device.device_token)
    if sns_response.present? && sns_response.http_response.status == 200
      Device.where(user_id: current_user).each do |device|
        endpoint_response = delete_endpoint(device.aws_endpoint_arn)
        next if endpoint_response.nil? || endpoint_response.http_response.status != 200
        raise InternalServerErrorException unless device.destroy
      end
      @device.aws_endpoint_arn = sns_response.endpoint_arn
      raise InternalServerErrorException unless @device.save
    end
    render nothing: true
  end


  # swagger_path device/{id}
  swagger_path '/device/{id}' do
    operation :put do
      key :summary, 'Update device'
      key :description, 'Updates device information by ID'
      parameter do
        key :name, 'id'
        key :description, 'Device ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'device'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :DeviceInput
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', :DeviceInput
        end
      end # end response OK
      response 400 do
        key :description, 'Validation errors'
        schema do
          key :'$ref', :ValidationErrorsContainer
        end
      end
      # response Default
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response Default
      key :tags, ['Devices']
    end # end operation :put
    operation :delete do
      key :summary, 'Delete device'
      key :description, 'Deletes device by ID'
      parameter do
        key :name, 'id'
        key :description, 'Device ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      response 204 do
        key :description, 'Deleted'
      end
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :Error
        end
      end # end response default
      key :tags, ['Devices']
    end # end operation :delete
  end # end swagger_path /device/{id}

  def update
    @device.assign_attributes(device_params)
    @sns.delete_endpoint(endpoint_arn: @device.aws_endpoint_arn)
    sns_response = insert_token(@device.aws_endpoint_arn)
    if sns_response.present? && sns_response.http_response.status == 200
      # save new endpoint
      @device.aws_endpoint_arn = sns_response.endpoint_arn
      raise InternalServerErrorException unless @device.save
    end
    render nothing: true
  end

  # TODO: add to swagger_path
  def destroy
    @sns.delete_endpoint(endpoint_arn: @device.aws_endpoint_arn)
    @device.destroy
    render nothing: true, status: :no_content
  end

private
  def device_params
    params[:user_id] = current_user
    params.permit(:user_id,
    :device_token,
    :aws_endpoint_arn)
  end

  # Insert device token to SNS
  def insert_token(device_token)
    @sns.create_platform_endpoint(
        platform_application_arn: "iOS",
        token: device_token,
    )
  end

  # Remove end_point from SNS
  def delete_endpoint(end_point)
    @sns.delete_endpoint(endpoint_arn: end_point)
  end

end