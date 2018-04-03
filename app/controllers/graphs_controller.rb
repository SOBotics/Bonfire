class GraphsController < ApplicationController
  def posts_by_hour
    render json: Post.where('created_at > ?', 1.week.ago).group_by_hour(:created_at).count
  end
end
