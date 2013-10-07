class UserController < ApplicationController
  filter_resource_access :collection => [], :new => [], :additional_member => {:add_role => :update, :remove_role => :update, :add_brownie => :add_brownie, :admin_email => :email, :send_admin_email => :email, :su => :su}, :context => :users

  def permitted_params
    @_permitted_attributes ||= begin
      permitted_attributes = [:name, :avatar, :remove_avatar, :avatar_cache]
      permitted_attributes << :brownie_points if permitted_to? :add_brownie, @user
    end
    params.require(:user).permit(*@_permitted_attributes)
  end

  def show
    @solved_problems = @user.get_solved

    respond_to do |format|
      format.html
      format.xml {render :xml => @user }
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @user.update_attributes(permitted_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.xml { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def add_role
    role = Role.find(params[:user][:role_ids])
    permitted_to! :grant, role
    if @user.roles.exists?(role)
      redirect_to(@user, :alert => "This user already has this role")
      return
    end
    @user.roles.push(role)
    redirect_to(@user, :notice => "Role #{role.name} added.")
  end
  def remove_role
    role = Role.find(params[:role_id])
    permitted_to! :revoke, role
    @user.roles.delete(role)
    redirect_to(@user, :notice => "Role #{role.name} removed.")
  end

  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml { head :ok }
    end
  end

  def su
    if request.post?
      if current_user.valid_password?(params[:password])
        session[:su] = (session[:su]||[]).push(current_user.id)
        sign_in @user
        redirect_to root_url, :notice => "su #{@user.username}"
      else
        redirect_to request.referrer, :alert => "Password incorrect"
      end
    else
      render "users/su", :layout => !request.xhr?
    end
  end

  def add_brownie
    logger.debug "adding brownie"
    @user.brownie_points += 1
    @user.save
    redirect_to user_path(@user), :notice => "Brownie point added."
  end

  def admin_email
  end
  def send_admin_email
    AdminMailer.custom_email(current_user,@user,params[:subject],params[:body]).deliver
    redirect_to user_path(@user), :notice => "Email sent."
  end
end
