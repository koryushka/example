class DeviseOverrides::PasswordsController < DeviseTokenAuth::PasswordsController
  def update
    # make sure user is authorized
    unless @resource
      return render_update_error_unauthorized
    end

    # make sure account doesn't use oauth2 provider
    unless @resource.provider == 'email'
      return render_update_error_password_not_required
    end

    # ensure that password params were sent
    unless password_resource_params[:password] and password_resource_params[:password_confirmation]
      return render_update_error_missing_password
    end

    @resource.allow_password_change = true
    @resource.save!

    if @resource.send(resource_update_method, password_resource_params)
      @resource.allow_password_change = false

      yield if block_given?
      render_update_success
    else
      render_update_error
    end
  end

protected

  # def resource_update_method
  #   @resource.allow_password_change = @resource.reset_password_token.present?&&
  #       resource_params[:reset_password_token] == @resource.reset_password_token
  #   super
  # end
end