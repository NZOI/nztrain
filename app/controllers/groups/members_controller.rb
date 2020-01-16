class Groups::MembersController < ApplicationController
  layout 'group'

  private
  def load_group_request
    @group = Group.find(params[:id])
    @request = Request.find(params[:request_id])
    if @group.invitations.exists?(@request) && @request.pending?
      @request_type = :invitation
    elsif @group.join_requests.exists?(@request) && @request.pending?
      @request_type = :join_request
    else
      redirect_to(@group, :alert => 'Invalid request operation')
    end
  end

  public
  def index
    @group = Group.find(params[:id])
    authorize @group, :access?
    @memberships = @group.memberships.includes(:member).order(:created_at).reverse_order
  end

  def add
    @group = Group.find(params[:id])
    authorize @group, :add_user?
    @user = User.find_by_username(params[:username])
    if @user.nil?
      redirect_to(members_group_path(@group), :alert => "No user found with username \"#{params[:username]}\"")
    elsif @group.members.exists?(@user)
      redirect_to(members_group_path(@group), :alert => "#{@user.username} is already a member of this group")
    else
      @group.join(@user)
      redirect_to(members_group_path(@group), :notice => "#{@user.username} has been added to this group")
    end
  end

  def remove
    @group = Group.find(params[:id])
    authorize @group, :remove_user?
    @user = User.find(params[:user_id])
    @group.members.delete(@user)
    redirect_to(members_group_path(@group), :notice => "#{@user.username} has been removed from this group")
  end

  def join
    @group = Group.find(params[:id])
    authorize @group, :join?
    if @group.join(current_user)
      redirect_to(@group, :notice => "You are now a member of this group")
    else
      redirect_to(@group, :alert => "You are already a member of this group")
    end
  end

  def leave
    @group = Group.find(params[:id])
    authorize @group, :leave?
    @group.members.delete(current_user)
    redirect_to(@group.visibility == Group::VISIBILITY[:private] ? browse_groups_path : info_group_path(@group), :notice => "You are no longer a member of this group")
  end

  def apply
    @group = Group.find(params[:id])
    authorize @group, :apply?
    if @group.members.exists?(current_user)
      redirect_to(@group, :alert => "You are already a member of this group")
    elsif invitation = @group.invitations.pending.where(:target_id => @user).first
      invitation.accept!
      redirect_to(@group, :notice => "You have accepted an invitation to join the group")
    elsif @group.join_requests.pending.where(:subject_id => @user).first
      redirect_to(@group, :alert => "You already have a pending join request for this group")
    else
      @group.apply!(current_user)
      redirect_to(@group, :notice => "You have applied to join this group")
    end
  end

  def invites
    @group = Group.find(params[:id])
    authorize @group, :invite?
    if request.post?
      @user = User.find_by_username(params[:username])
      if @user.nil?
        redirect_to(invites_members_group_path(@group), :alert => "No user found with username \"#{params[:username]}\"")
      elsif @group.members.exists?(@user)
        redirect_to(invites_members_group_path(@group), :alert => "#{@user.username} is already a member of this group")
      elsif join_request = @group.join_requests.pending.where(:subject_id => @user).first
        join_request.accept!
        redirect_to(invites_members_group_path(@group), :notice => "#{@user.username}'s join request has been accepted")
      elsif @group.invitations.pending.where(:target_id => @user).first
        redirect_to(invites_members_group_path(@group), :alert => "#{@user.username} has already been invited to join this group")
      else
        @group.invite!(@user, current_user)
        redirect_to(invites_members_group_path(@group), :notice => "#{@user.username} has been invited to join this group")
      end
    else # get request
      @pending_requests = @group.invitations.pending.order(:created_at).reverse_order
      @requests = @group.invitations.closed.order(:created_at).reverse_order
    end
  end

  def join_requests
    @group = Group.find(params[:id])
    authorize @group, :invite?
    @pending_requests = @group.join_requests.pending.order(:created_at).reverse_order
    @requests = @group.join_requests.closed.order(:created_at).reverse_order
  end

  def accept
    load_group_request
    case @request_type
    when :invitation; authorize @request, :accept?
    when :join_request; authorize @group, :invite?
    else raise Pundit::NotAuthorizedError
    end
    if @request_type == :invitation
      if @group.join(@request.target)
        @request.accept!
        redirect_to(@group, :notice => "Invitation accepted")
      else
        redirect_to(@group, :alert => "Failed to join group")
      end
    else # :join_request
      if @group.join(@request.subject)
        @request.accept!
        redirect_to(join_requests_members_group_path(@group), :notice => "Join request accepted")
      else
        redirect_to(@group, :alert => "Failed to accept join request")
      end
    end
  end

  def reject
    load_group_request
    case @request_type
    when :invitation, :join_request; authorize @group, :reject?
    else raise Pundit::NotAuthorizedError
    end
    @request.reject!
    if @request_type == :invitation
      redirect_to(@group, :notice => "Invitation rejected")
    else # :join_request
      redirect_to(join_requests_members_group_path(@group), :notice => "Join request rejected")
    end
  end

  def cancel
    load_group_request
    case @request_type
    when :invitation; policy(@group).reject? or authorize @request, :cancel?
    when :join_request; authorize @group, :cancel?
    else raise Pundit::NotAuthorizedError
    end
    @request.cancel!
    if @request_type == :invitation
      redirect_to(invites_members_group_path(@group), :notice => "Invitation cancelled")
    else # :join_request
      redirect_to(@group, :notice => "Join request cancelled")
    end
  end
end

