json.items(@results) do |reason|
  json.merge! reason.as_json
end

json.has_more has_more(@count, @pagesize, params[:page])
