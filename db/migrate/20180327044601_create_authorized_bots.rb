class CreateAuthorizedBots < ActiveRecord::Migration[5.1]
  def change
    create_table :authorized_bots do |t|
      t.string :name
      t.string :key

      t.timestamps
    end
  end
end
