class CreatePostLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :post_logs do |t|
      t.references :post, foreign_key: true
      t.boolean :is_deleted
      t.boolean :is_closed
      t.datetime :deletion_date
      t.datetime :close_date
      t.string :close_reason

      t.timestamps
    end
  end
end
