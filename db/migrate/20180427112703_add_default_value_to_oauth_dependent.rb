class AddDefaultValueToOauthDependent < ActiveRecord::Migration[5.1]
  def up
    change_column_default :users, :oauth_dependent, false
  end

  def down
    change_column_default :users, :oauth_dependent, nil
  end
end
