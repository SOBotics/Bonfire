class AddDefaultValueToOauthSkipped < ActiveRecord::Migration[5.1]
  def up
    change_column_default :users, :oauth_skipped, false
  end
  
  def down
    change_column_default :users, :oauth_skipped, nil
  end
end
