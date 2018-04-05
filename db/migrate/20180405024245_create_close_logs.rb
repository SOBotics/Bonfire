class CreateCloseLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :close_logs do |t|
      t.references :post, foreign_key: true
      t.boolean :is_closed

      t.timestamps
    end
  end
end
