class Accounts::RegistrationsController < Devise::RegistrationsController

  def resource_params
    @_permitted_attributes ||= begin
      permitted_attributes = []
      if action_name == "update"
        permitted_attributes = [:current_password]
        permitted_attributes << :email if params[:type] == "email"
        if current_user.confirmed?
          permitted_attributes << :username if current_user.can_change_username && params[:type] == "username"
          permitted_attributes << :password << :password_confirmation if params[:type] == "password"
        end
      elsif action_name == "create"
          permitted_attributes = [:username, :name, :email, :password, :password_confirmation]
      end
      permitted_attributes
    end
    params.require(:user).permit(*@_permitted_attributes)
  end
  private :resource_params

  def edit
    params[:type] = 'email' if !current_user.confirmed?
    params[:type] = 'password' if !params.has_key?(:type)
    super
  end

  def create
    if (!@db_settings["recaptcha/private_key"]) || (@db_settings["recaptcha/private_key"].empty?) || verify_recaptcha(:private_key => @db_settings["recaptcha/private_key"])
        super
    else
      build_resource
      clean_up_passwords(resource)
      flash.now[:alert] = "There was an error with the recaptcha code below. Please re-enter the code."      
      flash.delete :recaptcha_error
      render :new
    end
  end

  protected :after_update_path_for
  def after_update_path_for(resource)
    if !current_user.confirmed?
      if params[resource_name][:email] != self.resource.email
        flash[:notice] = "Email pending confirmation - confirmation instructions have been sent to #{params[resource_name][:email]}. The email will be changed as soon as it has been confirmed."
      else
        flash[:notice] = "Email has not been changed."
        self.resource.unconfirmed_email = self.resource.email
        resource.save
      end
      return edit_user_registration_path + '/email'
    end
    user_path(resource)
  end
end

