class PostLog < ApplicationRecord
  belongs_to :post

  validates :is_deleted, :inclusion => [true, false]
  validates :is_closed, :inclusion => [true, false]
  validates :close_vote_count, :inclusion => 0..5

  def self.get_statuses
    api_key = AppConfig['se_api_key']
    api_filter = '!)R7_YDvFk_s2DCKPUucfUyln'
    eligible = Post.left_joins(:post_log)

    eligible = eligible.where(:post_log.nil?)
                .or(eligible.where("post_log.is_deleted = ?", false))

    eligible = eligible.where('posts.created_at > ?', 4.weeks.ago)
    logger.debug "[PostLog#get_statuses] Count #{eligible.count} posts for PostLog checking."

    eligible.in_groups_of(100, false).each do |group|
      current_date = DateTime.current
      ids = group.pluck(:question_id)
      url = "https://api.stackexchange.com/2.2/questions/#{ids.join(';')}?pagesize=100&site=stackoverflow&key=#{api_key}&filter=#{api_filter}"
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
            unless log.is_deleted
              log.update(:is_deleted => true, :deletion_date => current_date)
            end
          else
            PostLog.create(:post => post, :is_deleted => true, :deletion_date => current_date, :close_vote_count => 0)
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
              unless log.is_closed
                log.update(:is_closed => true, :close_vote_count => 0, :close_reason => item['closed_reason'], :close_date => closed_date)
              end
            else
              PostLog.create(:post => post, :is_closed => true, :close_vote_count => 0, :close_reason => item['closed_reason'], :close_date => closed_date)
            end
          elsif item.key?("close_vote_count")
            if post.post_log.present?
              log = post.post_log
              unless log.is_closed || log.close_vote_count == item['close_vote_count']
                log.update(:is_closed => false, :close_vote_count => item['close_vote_count'])
              end
            else
              PostLog.create(:post => post, :is_closed => false, :close_vote_count => item['close_vote_count'])
            end
          end
        end

        logger.debug "[PostLog#get_statuses] #{total_closed} posts of 100-batch posts have been closed." 
        
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
