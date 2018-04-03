class CreateFlags < ActiveRecord::Migration[5.1]
  def change
    create_table :flags do |t|
      t.references :post, foreign_key: true, type: :integer
      t.references :user, foreign_key: true, type: :integer
      t.string :flag_type

      t.timestamps
    end
  end
end
