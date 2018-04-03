json.items @results.each do |post|
  json.merge! post_as_json
end

json.has_more has_more(@count, @pagesize, params[:page])
