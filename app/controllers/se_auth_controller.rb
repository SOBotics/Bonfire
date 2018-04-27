class SeAuthController < ApplicationController
  include SeAuthHelper

  before_action :authenticate_user!, :except => [:login_target]
  before_action :verify_no_auth, :except => [:already_done, :deauth, :login_target]
  before_action :verify_partial_admin, :only => [:deauth]

  def initiate
  end

  def upgrade
  end

  def already_done
  end

  def redirect
    client_id = AppConfig['se_client_id']
    redirect_uri = url_for(:controller => :se_auth, :action => :target)
    scope = 'no_expiry,write_access'
    auth_state = Digest::SHA256.hexdigest("#{current_user.username}#{rand(0..9e9)}")
    
    current_user.auth_state = auth_state
    if current_user.save
      redirect_to "https://stackexchange.com/oauth?client_id=#{client_id}&redirect_uri=#{redirect_uri}&scope=#{scope}&state=#{auth_state}"
    else
      flash[:danger] = "Couldn't save a pre-auth token to your user account. Try again later, and contact a developer if the problem persists."
      redirect_to url_for(:controller => :se_auth, :action => :initiate)
    end
  end

  def target
    if current_user.auth_state.present? && current_user.auth_state == params[:state]
      token = current_user.get_access_token(params[:code], AppConfig['host'])

      stack_user = current_user.stack_user || StackUser.new(:user => current_user, :access_token => token)
      stack_user.access_token = token
      if stack_user.save
        if stack_user.update_details
          flash[:success] = "Authentication complete."
          redirect_to url_for(:controller => :se_auth, :action => :already_done)
        else
          flash[:danger] = "Can't update the user details for your user. Try again later, and contact a developer if the problem persists."
          redirect_to url_for(:controller => :se_auth, :action => :initiate)
        end
      else
        flash[:danger] = "Can't create a record for your StackExchange user. Try again later, and contact a developer if the problem persists."
        redirect_to url_for(:controller => :se_auth, :action => :initiate)
      end
    end
  end

  def login_target
    if user_signed_in?
      flash[:danger] = "You're already signed in."
      redirect_to(root_path) && return
    end

    redirect_uri = url_for(:host => AppConfig["host"], :protocol => "https", :controller => :se_auth, :action => :login_target)
    token = get_access_token_from_code(params[:code], redirect_uri)
    token_info = helpers.get_info_from_token(token)

    if not token
      flash[:danger] = "An error occurred while trying to fetch the access token from oAuth code. Try again later, and contact a developer if the problem persists."
      redirect_to(root_path) && return
    end

    user = nil

    User.all.each do |u|
      if u.stack_user.present?
        if u.stack_user.network_id == token_info['account_id']
          user = u
          break
        end
      end
    end

    if user
      flash[:success] = "Successfully logged in as #{user.username}!"
    else
      user = User.new(:email => "#{token_info['account_id']}@se-oauth.bonfire")
      user.oauth_dependent = true
      stack_user = StackUser.new(:user => user, :access_token => token)
      if stack_user.save
        unless stack_user.update_details
          flash[:danger] = "Can't update the user details for your user. Try again later, and contact a developer if the problem persists."
          redirect_to user_registration_path
        end
      else
        flash[:danger] = "Can't create a record for your StackExchange user. Try again later, and contact a developer if the problem persists."
      end

      user.username = stack_user.username
      user.password = user.password_confirmation = Digest::SHA256.hexdigest("#{Time.now}#{rand(0..9e9)}")

      unless user.save
        flash[:danger] = "Can't create a record for your user. Try again later, and contact a developer if the problem persists."
        redirect_to user_registration_path
      end

      flash[:success] = "#{user.username}, your account has been successfully created!"
    end
    sign_in_and_redirect user
  end

  def deauth
    @user = User.find params[:user_id]
    if @user.stack_user.destroy
      flash[:success] = "Removed SE auth details successfully."
    else
      flash[:danger] = "Failed to remove SE auth details."
    end
    redirect_to url_for(:controller => :users, :action => :show, :id => @user.id)
  end

  private
    def verify_no_auth
      if current_user.stack_user.present? && helpers.get_info_from_token(current_user.stack_user.access_token).key?("scope")
        redirect_to url_for(:controller => :se_auth, :action => :already_done)
      end
    end

    def verify_partial_admin
      unless params[:user_id] == current_user.id
        verify_admin
      end
    end
end
