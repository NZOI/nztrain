class Accounts::RegistrationsController < Devise::RegistrationsController
  def create
    if (!@db_settings["recaptcha/private_key"]) || @db_settings["recaptcha/private_key"].empty? || verify_recaptcha(secret_key: @db_settings["recaptcha/private_key"])
      flash.delete :recaptcha_error
      super
    else
      flash.delete :recaptcha_error
      build_resource(sign_up_params)
      resource.valid?
      resource.errors.add(:base, "There was an error with the recaptcha code below. Please re-enter the code.")
      clean_up_passwords(resource)
      respond_with resource
    end
  end

  def destroy
    redirect_to root_path, alert: "Sorry. This feature is disabled. Why? Because cleanup of database objects associated with a user is not implemented."
  end
end
