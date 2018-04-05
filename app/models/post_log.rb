class PostLog < ApplicationRecord
  belongs_to :post

  validates :is_deleted, :presence => true
  validates :is_closed, :presence => true
  validates :close_vote_count, :presence => true
  validates :deletion_date, :presence => true, if: Proc.new { |x| x.is_deleted? }
  validates :close_date, :presence => true, if: Proc.new { |x| x.is_closed? }
  validates :close_reason, :presence => true, if: Proc.new { |x| x.is_closed? }

  def self.get_statuses
    api_key = AppConfig['se_api_key']
    api_filter = '!)R7_YDvFk_s2DCKPUucfUyln'
    posts = Post.left_joins(:post_log)

    eligible = posts.where(:post_log.nil?)
                #.or(posts.where(:post_log => {:is_deleted => false}))

    eligible = eligible.where('posts.created_at > ?', 4.weeks.ago)
    puts eligible
    logger.debug "[PostLog#get_statuses] Count #{eligible.count} posts for PostLog checking."

    eligible.in_groups_of(100, false).each do |group|
      current_date = DateTime.current
      ids = group.pluck(:question_id)
      url = "https://api.stackexchange.com/2.2/questions/#{ids.join(';')}?site=stackoverflow&key=#{api_key}&filter=#{api_filter}"
      response = HTTParty.get(url)
      if response.code == 200
        json = response.parsed_response
        
        fetched_ids = []
        json['items'].each do |item|
          fetched_ids << item['question_id'].to_i
        end

        deleted_ids = ids - fetched_ids
        logger.debug "[PostLog#get_statuses] #{deleted_ids.length} of 100-batch posts have been deleted."
        deleted_ids.each do |id|
          post = Post.find_by_question_id id
          if post.post_log.present?
            log = post.post_log
            log.is_deleted = true
            log.deletion_date = current_date
            unless log.save
              logger.error "[PostLog#get_statuses] Unable to save post log for post id: #{post.question_id}"
            end
          else
            log = PostLog.create(:post => post, :is_closed => false, :close_vote_count => 0, :is_deleted => true, :deletion_date => current_date)
          end
        end

        total_closed = 0
        json['items'].each do |item|
          id = item['question_id']
          post = Post.find_by_question_id id
          if item.key?("closed_date")
            total_closed += 1
            closed_date = Time.at(item['closed_date']).to_datetime
            if post.post_log.present?
              log = post.post_log
              log.close_vote_count = 0
              log.is_closed = true
              log.close_reason = item['closed_reason']
              log.close_date = closed_date
              unless log.save
                logger.error "[PostLog#get_statuses] Unable to save post log for post id: #{post.question_id}"
              end
            else
              PostLog.create(:post => post, :is_deleted => false, :is_closed => true, :close_vote_count => 0, :close_reason => item['closed_reason'], :close_date => closed_date)
            end
          end
        end 
        
        if json['backoff']
          logger.debug "[PostLog#get_statuses] Received API backoff; sleeping for #{json['backoff']} seconds."
          sleep json['backoff']
        end
      else
        logger.error "[PostLog#get_statuses] Received #{response.code} from API: #{response.body}"
      end
    end
  end  
end
