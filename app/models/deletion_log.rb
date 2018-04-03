class DeletionLog < ApplicationRecord
  belongs_to :post

  validates :is_deleted, :presence => true

  def self.get_statuses
    eligible = Post.left_joins(:deletion_logs).where(:deletion_logs => {:id => nil}).where('posts.created at > ?', 2.years.ago)
    logger.debug "[DeletionLog#get_statuses] Counted #{eligible.count} Posts eligible for DeletionLog checking."

    eligible.in_groups_of(100, false).each do |group|
      ids = group.pluck(:question_id)
      url = "https://api.stackexchange.com/2.2/questions/#{ids.join(';')}?site=stackoverflow&key=#{AppConfig['se_api_key']}"
      
      response = HTTParty.get(url)
      if response.code == 200
        json = response.parsed_response
        remaining_ids = []
        json['items'].each do |item|
          remaining_ids << item['question_id'].to_i
        end

        deleted_ids = ids - remaining_ids
        logger.debug "[DeletionLog#get_statuses] #{deleted_ids.length} of 100-batch of Posts have been deleted."

        deleted_ids.each do |deleted_id|
          post = Post.find_by_question_id deleted_id
          DeletionLog.create(:post => post, :is_deleted => true)
        end
      
        if json['backoff']
          logger.debug "[DeletionLog#get_statuses] Received API backoff; sleeping for #{json['backoff']} seconds."
          sleep json['backoff']
        end
      else
        logger.error "[DeletiomLog#get_statuses] Received #{response.code} from SE API: #{response.body}"
      end
    end
  end
end
