class UsersController < ApplicationController
  before_filter :check_signed_in
  load_and_authorize_resource
  skip_authorize_resource :only => [:add_role, :remove_role]

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
      format.xml {render :xml => @users }
    end
  end

  def edit
  end

  def update

    @user.accessible = [:brownie_points] if can? :add_brownie, @user

    respond_to do |format|
      if @user.update_attributes(params[:user])
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

  def add_brownie
    
    authorize! :add_brownie, @user
    logger.debug "adding brownie"
    @user.brownie_points += 1
    @user.save
    redirect_to @user, :notice => "Brownie point added."
  end

end
