class Accounts::ConfirmationsController  < Devise::ConfirmationsController 
  def after_resending_confirmation_instructions_path_for(resource_name)
    if user_signed_in? && !current_user.confirmed?
      flash[:notice] = "Confirmation instructions sent to #{resource.unconfirmed_email || resource.email}."
      return edit_user_registration_path + '/email'
    end
    new_session_path(resource_name)
  end
end

