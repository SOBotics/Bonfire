class ReviewController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_stack_auth
  helper_method :seed_count
  helper_method :close_count

  def index
  end

  def create
    review_action = ReviewAction.find_by_short_name params[:review_action]
    user = current_user
    post = Post.find_by_id params[:post_id].to_i

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

  def seed_count
    posts = get_seed_posts
    return posts.count
  end

  def close_count
    posts = get_close_posts
    return posts.count
  end

  def seed_review
    @posts = get_seed_posts
    @posts = @posts.paginate(:page => params[:page], :per_page => 60) 
  end

  def close_review
    @posts = get_close_posts
    @posts = @posts.paginate(:page => params[:page], :per_page => 60)     
  end

  private
    def verify_stack_auth
      unless current_user.stack_user.present?
        flash[:danger] = "You need to authenticate with StackExchange to use review."
        redirect_to url_for(:controller => :se_auth, :action => :initiate)
      end
    end
  
    def get_seed_posts
      eligible = Post.where('posts.created_at > ?', 9.days.ago)
      eligible = eligible.left_joins(:post_log).where('close_vote_count = ? AND is_deleted = ? AND is_closed = ?', 0, false, false)
      eligible = eligible.left_joins(:reviews).where(:reviews => {:id => nil})
                  .or(eligible.left_joins(:reviews).where.not(:reviews => {:user_id => current_user.id}))
      return eligible
    end

    def get_close_posts
      eligible = Post.left_joins(:post_log).where('close_vote_count > ? AND is_deleted = ? AND is_closed = ?', 0, false, false)
      eligible = eligible.left_joins(:reviews).where(:reviews => {:id => nil})
                  .or(eligible.left_joins(:reviews).where.not(:reviews => {:user_id => current_user.id}))
      return eligible
    end
end
