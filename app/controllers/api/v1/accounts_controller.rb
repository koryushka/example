class Api::V1::AccountsController < ApiController

  before_filter(except: [:index, :create]) { find_entity_of_current_user(type:GoogleAccessToken, property_name: 'account') }

  def index
    @accounts = current_user.google_access_tokens
  end

  def update
    if @account.update_attributes(account_params)
      @account.remove_calendars if params[:synchronizable] == false
      render json: {account: @account}
    else
      raise InternalServerErrorException    
    end
  end

  def show
    render json: {account: @account}
  end

  private

  def account_params
    params.require(:account).permit(:synchronizable)
  end
end
