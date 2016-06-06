class Api::V1::DevicesController < ApiController
  include Swagger::Blocks

  before_filter :find_entity, except: [:create]

  authorize_resource
  check_authorization

  # swagger_path /device
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
    sns = ApiHelper::Sns.new
    @device = Device.find_by(device_token: device_params[:device_token])
    if @device
        endpoint_response = sns.delete_endpoint(@device.aws_endpoint_arn)
        if endpoint_response.present? && endpoint_response.successful?
          raise InternalServerErrorException unless @device.destroy
        else
          raise SnsUnsuccessfulException.new({message: 'Response is empty or unsuccessful'})
        end
    end
    
    @device = current_user.devices.build(device_params)
    return render json: :ValidationErrorsContainer, status: :bad_request if @device.invalid?

    sns_response = sns.insert_token(@device.device_token)
    if sns_response.present? && sns_response.successful?
      @device.aws_endpoint_arn = sns_response.endpoint_arn
      raise InternalServerErrorException unless @device.save
    else
      raise SnsUnsuccessfulException.new({message: 'Response is empty or unsuccessful'})
    end
    render partial: 'device', status: :created
  end

  # swagger_path /devices/{id}
  swagger_path '/devices/{id}' do
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
  end # end swagger_path /devices/{id}
  def destroy
    sns = ApiHelper::Sns.new
    sns_response = sns.delete_endpoint(@device.aws_endpoint_arn)
    if sns_response.present? && sns_response.successful?
      raise InternalServerErrorException unless@device.destroy
    else
      raise SnsUnsuccessfulException.new({message: 'Response is empty or unsuccessful'})
    end
    render nothing: true, status: :no_content
  end

private
  def device_params
    params.permit(:user_id, :device_token, :aws_endpoint_arn)
  end
end