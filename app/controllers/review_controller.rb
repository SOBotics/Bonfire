class ReviewController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_stack_auth

  def index
  end

  def create
    review_action = ReviewAction.find_by_short_name params[:review_action]
    user = current_user
    post = Post.find_by_id params[:id].to_i

    @review = Review.new
    @review.review_action = review_action
    @review.user = user
    @review.post = post
    
    if @review.save
      render :create, :formats => :json
    else
      messages = @review.errors.full_messages
      render :json => {:status => "E:REVIEW_FAILED_TO_SAVE", :code => "500", :messages => messages}, :status => 500
    end
  end

  def seed_review
    @posts = Post.where('created_at > ? AND (post_log = ? OR (post_log.is_closed = ? AND post_log.is_deleted = ?))', 14.days.ago, nil, false, false)
  end

  def close_review
    @posts = Post.left_joins(:post_log).where('close_vote_count > ? AND is_deleted = ? AND is_closed = ?', 0, false, false)
    @posts = @posts.left_joins(:reviews).where(:reviews => {:id => nil})
              .or(@posts.left_joins(:reviews).where.not(:reviews => {:user_id => current_user.id}))
    @posts.limit(100)
  end

  private
    def verify_stack_auth
      unless current_user.stack_user.present?
        flash[:danger] = "You need to authenticate with StackExchange to use review."
        redirect_to url_for(:controller => :se_auth, :action => :initiate)
      end
    end
end
