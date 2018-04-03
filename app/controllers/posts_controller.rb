class PostsController < ApplicationController
  before_action :set_post, :only => [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, :only => [:edit, :update, :destroy, :flag_options, :cast_flag]
  before_action :verify_admin, :only => [:edit, :update, :destroy]
  before_action :verify_bot_authorized, :only => [:create]
  before_action :check_can_flag, :only => [:cast_flag, :flag_options]
  skip_before_action :verify_authenticity_token, :only => [:create]
  
  def create
    site = Site.find_by_url params[:site]
    @post = Post.new post_params
    @post.site = site

    if @post.save
      params[:reasons].each do |reason|
        @reason = Reason.find_or_create_by(name: reason)
        @reason.posts << @post
        unless @reason.save
          render :json => {:status => "E:REASON_FAILED_TO_SAVE", :code => "500.2" }, :status => 500
        end
      end
      if @post.save
        @post.reasons.each do |each_reason|
          Rails.cache.delete("reason_#{each_reason.id}_most_recent")
        end

        render :create, :formats => :json
      else
        render :json => {:status => "E:POST_FAILED_TO_SAVE", :code => "500.3"}, :status => 500
      end
    else
      messages = @post.errors.full_messages
      render :json => {:status => "E:POST_FAILED_TO_SAVE", :code => "500.1", :messages => messages}, :status => 500
    end
  end

  def index
    @posts = Post.all.order(params[:sort] || 'created_at desc', 'id desc').paginate(:page => params[:page], :per_page => 75)
  end

  def show
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to url_for(:controller => :posts, :action => :show, :id => @post.id)
    else
      render :edit
    end
  end

  def destroy
    if @post.destroy
      flash[:success] = "Removed post #{@post.id}."
      redirect_to url_for(:controller => :posts, :action => :index)
    else
      render :show
    end
  end

  def by_post_id
    @post = Post.find_by_post_id(params[:id])
    if @post.present?
      redirect_to url_for(:controller => :posts, :action => :show, :id => @post.id)
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def flag_options
    response = HTTParty.get(api_url("/questions/#{params[:question_id]}/flags/options", current_user, {:site => 'stackoverflow'}))
    render :json => response.body, :status => response.code
  end

  def cast_flag
    puts "CAST_FLAG CALLED"
    opts = { :option_id => params[:option_id].to_i, :key => AppConfig['se_api_key'], :preview => false,
             :access_token => current_user.stack_user.access_token, :site => 'stackoverflow', :id => params[:question_id].to_i }

    if params[:comment].present?
      opts[:comment] = params[:comment]
    end

    response = HTTParty.post("https://api.stackexchange.com/2.2/questions/#{params[:question_id]}/flags/add", :body => opts)
    if response.code == 200
      flag = Flag.new(:post => Post.find_by_question_id(params[:question_id]), :user => current_user, :flag_type => params[:flag_type])
      unless flag.save
        render :json => {:error_message => flag.errors.full_messages.map{ |m| m.downcase! }.to_sentence.capitalize }, :status => 500
      end
    end
    render :json => response.body, :status => response.code
  end

  def not_flaggable
  end 

  private
    def post_params
      params.require(:post).permit(:title, :body, :link, :post_creation_date, :user_link, :username, :user_reputation, :likelihood, :question_id)
    end

    def set_post
      @post = Post.find params[:id]
    end

    def check_can_flag
      unless current_user&.stack_user
        render :not_flaggable, :status => 400, :formats => :json
      end
    end 
end
