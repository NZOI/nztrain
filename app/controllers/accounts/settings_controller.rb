class Accounts::SettingsController < Devise::RegistrationsController

  def update # try update the username with password if username can be changed
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if resource.update_without_password(params[resource_name])
      sign_in resource_name, resource, :bypass => true
      flash[:notice] = "Account updated"
      respond_with resource, :location => after_update_path_for(resource)
    else
      if !resource.errors[:avatar].nil?
        resource.remove_avatar!
      end
      respond_with resource
    end
  end

  def edit
  end

  undef create

  undef new

  protected :after_update_path_for
  def after_update_path_for(resource)
    user_path(resource)
  end
end

