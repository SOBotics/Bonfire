module ApplicationHelper
  def get_info_from_token(access_token)
    api_key = AppConfig['se_api_key']
    JSON.parse(HTTParty.get("https://api.stackexchange.com/2.2/access-tokens/#{access_token}?key=#{api_key}").body)['items'][0]
  end
end
