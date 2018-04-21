class Site < ApplicationRecord
  has_many :posts

  def self.update_site_list
    require 'net/http'
    
    url_string = "https://api.stackexchange.com/2.2/sites?pagesize=1000&filter=!*L1-85AFULD6pPxF&key=#{AppConfig["se_api_key"]}"
    url = url = URI.parse(url_string)
    res = Net::HTTP.get_response(url)
    sites = JSON.parse(res.body)["items"]
    if sites.count > 100 # Sites count should be at least 100; else, something is wrong.
      sites.each do |site|
        s = Site.find_or_create_by(:domain => URI.parse(site["site_url"]).host)
        s.url = site["site_url"]
        s.logo = site["favicon_url"].gsub(/https?:/, "")
        s.name = site["name"]
        s.is_child_meta = site["site_type"] == "meta_site"
        s.save!
      end
    end
  end
end
