class GraphsController < ApplicationController
  before_action :authenticate_user!, :except => [:posts_by_hour]

  def index
  end

  # Taken from https://github.com/Charcoal-SE/metasmoke/blob/d6b7176b94e13170c7d5a37df4d1d3e617ef3cc8/app/controllers/graphs_controller.rb
  def cached_query(cache_key, **opts)
    opts[:expires_in] ||= 1.hour
    opts[:param_name] ||= :cache
    opts[:always_cache] ||= false

    if opts[:always_cache] || params[opts[:param_name]].present?
      Rails.cache.fetch cache_key, expires_in: opts[:expires_in] do
        yield
      end
    else
      yield
    end
  end

  def posts_by_hour
    render json: Post.where('created_at > ?', 1.week.ago).group_by_hour(:created_at).count
  end

  def post_statuses
    likelihood = params[:likelihood].to_i
    data = cached_query :post_statuses_graph do 
      [
        [
          'Closed',
          ((PostLog.where(is_closed: true)).left_joins(:post).where('likelihood <= ?', likelihood)).count
        ],
        [
          'Deleted',
          ((PostLog.where(is_deleted: true)).left_joins(:post).where('likelihood <= ?', likelihood)).count
        ],
        [
          'Other',
          ((PostLog.where('is_closed = false AND is_deleted = false')).left_joins(:post).where('likelihood <= ?', likelihood)).count

        ]
      ]
    end
    render json: data
  end
end
