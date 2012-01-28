class Accounts::RegistrationsController < Devise::RegistrationsController

  def update # try update the username with password if username can be changed
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    @can_change_username = resource.can_change_username
    if @can_change_username && params[resource_name][:username] && params[resource_name][:username] != resource.username
      resource.accessible = [:username, :can_change_username]
      params[resource_name][:can_change_username] = false
    end
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
      respond_with resource
    end
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
      resource.errors.add(:base, "There was an error with the recaptcha code below. Please re-enter the code.")
      render_with_scope :new
    end
  end
end

