class UsersController < ApplicationController
  load_and_authorize_resource
  skip_authorize_resource :only => [:add_role, :remove_role, :suexit, :admin_email, :send_admin_email]

  def permitted_params
    @_permitted_attributes ||= begin
      permitted_attributes = [:name, :avatar, :remove_avatar, :avatar_cache]
      permitted_attributes << :brownie_points if can? :add_brownie, @user
    end
    params.require(:user).permit(*@_permitted_attributes)
  end

  def index
    @users = @users.distinct.num_solved.order(:email)
    respond_to do |format|
      format.html
      format.xml {render :xml => @users }
    end
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
    authorize! :grant, role
    if @user.roles.exists?(role)
      redirect_to(@user, :alert => "This user already has this role")
      return
    end
    @user.roles.push(role)
    redirect_to(@user, :notice => "Role #{role.name} added.")
  end
  def remove_role
    role = Role.find(params[:role_id])
    authorize! :revoke, role
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
    if current_user.valid_password?(params[:password])
      session[:su] = (session[:su]||[]).push(current_user.id)
      sign_in @user
      redirect_to root_url, :notice => "su #{@user.username}"
    else
      redirect_to request.referrer, :alert => "Password incorrect"
    end
  end

  def suexit
    if (!session[:su]) || session[:su].empty?
      raise CanCan::AccessDenied.new("Not authorized!", :suexit, User)
    end
    old_user = current_user.username
    sign_in User.find(session[:su].pop)
    redirect_to request.referrer, :notice => "exit su #{old_user}"
  end

  def add_brownie
    authorize! :add_brownie, @user
    logger.debug "adding brownie"
    @user.brownie_points += 1
    @user.save
    redirect_to user_path(@user), :notice => "Brownie point added."
  end

  def admin_email
    authorize! :email, @user
  end
  def send_admin_email
    authorize! :email, @user
    AdminMailer.custom_email(current_user,@user,params[:subject],params[:body]).deliver
    redirect_to user_path(@user), :notice => "Email sent."
  end
end
