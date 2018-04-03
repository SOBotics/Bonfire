class AuthorizedBotsController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin
  before_action :set_bot, :only => [:destroy]

  def index
    @bots = AuthorizedBot.all
  end

  def new
    @bot = AuthorizedBot.new
    @bot.key = Digest::SHA256.hexdigest("#{Time.now}#{rand(0..9e9)}")
  end

  def create
    @bot = AuthorizedBot.new bot_params
    if @bot.save
      redirect_to url_for(:controller => :authorized_bots, :action => :index)
    else
      render :new
    end
  end

  def destroy
    unless @bot.destroy
      flash[:danger] = "Can't remove #{@bot.name}. This is most probably a bug."
    else
      flash[:success] = "Removed #{@bot.name}."
    end
    redirect_to url_for(:controller => :authorized_bots, :action => :index)
  end

  private
    def bot_params
      params.require(:authorized_bot).permit(:name, :key)
    end

    def set_bot
      @bot = AuthorizedBot.find params[:id]
    end
end
