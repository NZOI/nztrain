class UsersController < ApplicationController

  def index
    @users = User.all
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @users }
    end
  end

  def show
    @user = User.find(params[:id])
    
    respond_to do |format|
      format.html
      format.xml {render :xml => @users }
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

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

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml { head :ok }
    end
  end

end
