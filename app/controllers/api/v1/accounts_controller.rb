class Api::V1::AccountsController < ApiController
  include Swagger::Blocks

  before_filter(except: [:index, :create]) { find_entity_of_current_user(type:GoogleAccessToken, property_name: 'account') }

  def index
    @accounts = current_user.google_access_tokens.includes(:calendars)
  end

  swagger_path '/accounts' do
    operation :get do
      key :summary, 'Current user accounts'
      key :description, 'Returns all current user\'s accounts'
      # responses
      response 200 do
        key :description, 'OK'
        schema do
          key :'$ref', :ArrayOfAccounts
        end
      end # end response 200
      # response :default
      response :default do
        key :description, 'Unexpected error'
        schema do
          key :'$ref', :ErrorsContainer
        end
      end # end response :default
      key :tags, ['Accounts']
    end # end operation :get
  end # end swagger_path '/accounts'

  def update
    if @account.update_attributes(account_params)
      if params[:synchronizable] == false
        @account.remove_calendars
        @account.unsubscribe! if @account.google_channel
      elsif params[:synchronizable] == true
       # GoogleSyncService.new.sync(current_user.id, @account) # perform immediately
        GoogleWorker.perform_async(current_user.id, @account.id)
      end
      render :show, status: 204
    else
      raise InternalServerErrorException
    end
  end

  swagger_path '/accounts/{id}' do
    operation :put do
      key :summary, 'Update account'
      key :description, 'Updates account information by ID'
      parameter do
        key :name, 'id'
        key :description, 'Account ID'
        key :in, 'path'
        key :required, true
        key :type, :integer
      end
      parameter do
        key :name, 'account'
        key :in, 'body'
        key :required, true
        schema do
          key :'$ref', :AccountInput
        end
      end
      # responses
      response 201 do
        key :description, 'Updated'
        schema do
          key :'$ref', :AccountInput
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
      key :tags, ['Accounts']
    end # end operation :put
    operation :delete do
      key :summary, 'Delete account'
      key :description, 'Deletes account by ID'
      parameter do
        key :name, 'id'
        key :description, 'Account ID'
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
      key :tags, ['Accounts']
    end # end operation :delete
  end # end swagger_path ':/accounts/{id}'

  def destroy
    if @account.destroy
      @account.unsubscribe! if @account.google_channel
    end
    render nothing: true
  end
  private

  def account_params
    params.require(:account).permit(:synchronizable)
  end
end
