class AddOauthSkippedToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :oauth_skipped, :boolean
  end
end
