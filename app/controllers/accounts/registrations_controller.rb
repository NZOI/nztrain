class Accounts::RegistrationsController < Devise::RegistrationsController

  def update # try update the username with password if username can be changed
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    @can_change_username = resource.can_change_username
    if @can_change_username && params[resource_name][:username] && params[resource_name][:username] != resource.username
      resource.accessible = [:username, :can_change_username]
      params[resource_name][:can_change_username] = false
    end
    throw CanCan::AccessDenied if (!current_user.confirmed?) && (!params[resource_name].slice!(:email, :current_password).empty?) # can only update email if unconfirmed
    if resource.update_with_password(params[resource_name])
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      resource.can_change_username = @can_change_username
      clean_up_passwords resource
      params[:type] = params[resource_name].slice!(:current_password).keys.first
      respond_with resource
    end
  end

  def edit
    params[:type] = 'password' unless params[:type]
    params[:type] = 'email' if !current_user.confirmed?
    super
  end

  def build_resource(hash=nil) # create can access username
    super
    if params[resource_name] && params[resource_name][:username]
      self.resource.username = params[resource_name][:username] if params[resource_name][:username]
    end
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

