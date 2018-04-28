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

  def history
    @reviews = Review.all.order(:id => :desc).paginate(:page => params[:page], :per_page => 100)
  end 

  private
    def verify_stack_auth
      if current_user.oauth_skipped
        return
      end      

      if current_user.stack_user.present?
        token_info = helpers.get_info_from_token(current_user.stack_user.access_token)
        unless token_info.key?("scope")
          flash[:danger] = "You need to grant Bonfire write access with your StackExchange account to use review."
          redirect_to url_for(:controller => :se_auth, :action => :upgrade)
        end 
      else
        flash[:danger] = "You need to authenticate with StackExchange to use review."
        redirect_to url_for(:controller => :se_auth, :action => :initiate)        
      end
    end
  
    def get_seed_posts
      eligible = Post.where('posts.created_at > ?', 9.days.ago)
      eligible = eligible.left_joins(:post_log).where('close_vote_count = ? AND is_deleted = ? AND is_closed = ?', 0, false, false)
      eligible = eligible.left_joins(:reviews).where('reviews.id IS NULL OR reviews.user_id != ?', current_user.id)
      eligible = remove_reviewed(eligible)
      return eligible.distinct
    end

    def get_close_posts
      eligible = Post.left_joins(:post_log).where('close_vote_count > ? AND is_deleted = ? AND is_closed = ?', 0, false, false)
      eligible = eligible.left_joins(:reviews).where('reviews.id IS NULL OR reviews.user_id != ?', current_user.id)
      eligible = remove_reviewed(eligible)
      return eligible.distinct
    end

    # there should be an easier way to do this
    def remove_reviewed(posts)
      filtered_posts = posts
      posts.each do |post|
        post.reviews.each do |review|
          if review.user_id == current_user.id
            filtered_posts = filtered_posts.where.not(:id => post.id)
            break
          end
        end
      end
      return filtered_posts
    end
end
