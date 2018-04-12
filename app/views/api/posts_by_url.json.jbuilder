json.items @results.each do |post|
  json.merge! post.as_json
end

json.has_more has_more(@count, @pagesize, params[:page])
