module SeAuthHelper
  def get_access_token_from_code(code, redirect_uri)
    parameters = {
      :client_id => AppConfig['se_client_id'],
      :client_secret => AppConfig['se_client_secret'],
      :code => code,
      :redirect_uri => redirect_uri
    }

    response = HTTParty.post("https://stackexchange.com/oauth/access_token", :body => parameters)
    if response.code == 200
      response.parsed_response.split('=')[1].split("&exp")[0]
    else
      logger.error "Access token request returned status #{response.code}: #{response.body}"
      false
    end
  end

  def login_auth_url
    redirect_uri = Rails.application.routes.url_helpers.url_for(:host => AppConfig["host"], :protocol => "https", :controller => :se_auth, :action => :login_target)
    "https://stackexchange.com/oauth?client_id=#{AppConfig['se_client_id']}&scope=&redirect_uri=#{redirect_uri}"
  end
end
