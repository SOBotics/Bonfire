class AddOauthDependentToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :oauth_dependent, :boolean
  end
end
