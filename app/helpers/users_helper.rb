module UsersHelper
  def deauth_link
    url_for(:controller => "/se_auth", :action => :deauth, :user_id => current_user.id)
  end
  
  def auth_upgrade_link
    url_for(:controller => "/se_auth", :action => :upgrade)
  end

  def auth_initiate_link
    url_for(:controller => "/se_auth", :action => :initiate)
  end
end
