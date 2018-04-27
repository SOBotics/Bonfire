module UsersHelper
  def deauth_link
    url_for(:controller => "/se_auth", :action => :deauth, :user_id => current_user.id)
  end
end
