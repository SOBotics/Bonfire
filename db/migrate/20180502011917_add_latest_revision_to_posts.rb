class AddLatestRevisionToPosts < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :latest_revision, :text
  end
end
