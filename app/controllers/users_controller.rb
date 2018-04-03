class UsersController < ApplicationController
  before_action :authenticate_user!, :except => [:index]
  before_action :verify_admin, :except => [:index]
  before_action :set_user, :except => [:index]

  def index
    @users = User.all.paginate(:page => params[:page], :per_page => 75)
  end

  def promote
    @user.add_role(:admin)
    if @user.has_role?(:admin)
      flash[:success] = "Promoted #{@user.username} to admin."
    else
      flash[:danger] = "Promotion of #{@user.username} to admin failed! This is most probably a bug."
    end
    redirect_to url_for(:controller => :users, :action => :index)
  end

  def demote
    @user.remove_role(:admin)
    if @user.has_role?(:admin)
      flash[:danger] = "Removal of admin privileges for #{@user.username} has failed! This is most probably a bug."
    else
      flash[:success] = "Removed admin rights from #{@user.username}."
    end
    redirect_to url_for(:controller => :users, :action => :index)
  end

  def show
  end

  private
    def set_user
      @user = User.find params[:id]
    end 
end
