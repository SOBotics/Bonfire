class AddDefaultValueToPostLogs < ActiveRecord::Migration[5.1]
  def up
    change_column_default :post_logs, :is_closed, false
    change_column_default :post_logs, :is_deleted, false
    change_column_default :post_logs, :close_vote_count, 0
  end

  def down
    change_column_default :post_logs, :is_closed, nil
    change_column_default :post_logs, :is_deleted, nil
    change_column_default :post_logs, :close_vote_count, nil
  end
end
