class UserController < ApplicationController
  # this is for admins, users edit their own accounts using the accounts/ scope
  def permitted_params
    permitted_attributes = [:name, :avatar, :remove_avatar, :avatar_cache, :email, :school_id]
    permitted_attributes << :brownie_points if policy(@user).add_brownie?
    params.require(:user).permit(*permitted_attributes)
  end

  def show
    @user = User.find(params[:id])
    authorize @user, :show?
    @solved_problems = @user
      .user_problem_relations
      .where(ranked_score: 100)
      .joins(:problem)
      .select("problems.name", "problem_id", "ranked_submission_id")
      .order("problems.name")
  end

  def edit
    @user = User.find(params[:id])
    authorize @user, :edit?
  end

  def update
    @user = User.find(params[:id])
    authorize @user, :update?

    if @user.update_attributes(permitted_params)
      redirect_to(@user, notice: "User was successfully updated.")
    else
      render action: "edit"
    end
  end

  def add_role
    @user = User.find(params[:id])
    authorize @user, :update?
    role = Role.find(params[:user][:role_ids])
    authorize role, :grant?
    if @user.roles.exists?(role.id)
      redirect_to(@user, alert: "This user already has this role")
      return
    end
    @user.roles.push(role)
    redirect_to(@user, notice: "Role #{role.name} added.")
  end

  def remove_role
    @user = User.find(params[:id])
    authorize @user, :update?
    role = Role.find(params[:role_id])
    authorize role, :revoke?
    @user.roles.delete(role)
    redirect_to(@user, notice: "Role #{role.name} removed.")
  end

  def destroy
    @user = User.find(params[:id])
    authorize @user, :destroy?
    @user.destroy

    redirect_to(users_url)
  end

  def su
    @user = User.find(params[:id])
    authorize @user, :su?
    if request.post?
      if current_user.valid_password?(params[:password])
        session[:su] = (session[:su] || []).push(current_user.id)
        sign_in @user
        redirect_to root_url, notice: "su #{@user.username}"
      else
        redirect_to request.referrer || "/", alert: "Password incorrect"
      end
    else
      render "users/su", layout: !request.xhr?
    end
  end

  def add_brownie
    @user = User.find(params[:id])
    authorize @user, :add_brownie?
    logger.debug "adding brownie"
    @user.brownie_points += 1
    @user.save
    redirect_to user_path(@user), notice: "Brownie point added."
  end

  def admin_email
    @user = User.find(params[:id])
    authorize @user, :email?
  end

  def send_admin_email
    @user = User.find(params[:id])
    authorize @user, :email?
    AdminMailer.custom_email(current_user, @user, params[:subject], params[:body]).deliver
    redirect_to user_path(@user), notice: "Email sent."
  end
end
