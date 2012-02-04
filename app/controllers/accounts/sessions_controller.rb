class Accounts::SessionsController < Devise::SessionsController

  # GET /resource/sign_in
  def new
    resource = resource_class.new(nil)
    clean_up_passwords(resource)
    respond_with_navigational(resource, stub_options(resource)){ render_with_scope :new }
  end
end

