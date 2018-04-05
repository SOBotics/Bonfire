class AddCloseVoteCountToPostLogs < ActiveRecord::Migration[5.1]
  def change
    add_column :post_logs, :close_vote_count, :integer
  end
end
