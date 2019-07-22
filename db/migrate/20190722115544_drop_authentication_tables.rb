class DropAuthenticationTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :authentications
    drop_table :users
  end
end
