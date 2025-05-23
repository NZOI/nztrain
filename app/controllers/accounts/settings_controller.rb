class Accounts::SettingsController < Devise::RegistrationsController
  def permitted_params
    permitted_attributes = [:name, :avatar, :remove_avatar, :avatar_cache, :country_code, :school_id, {school_graduation: [:enabled, :month, :year], school: [:name, :country_code]}]
    params.require(:user).permit(*permitted_attributes)
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    if resource.update_without_password(permitted_params)
      flash[:notice] = "Account updated"
      respond_with resource, location: after_update_path_for(resource)
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
