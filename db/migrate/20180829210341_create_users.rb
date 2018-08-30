class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string   "email"#, null: false
      t.string   "first_name"#, null: false
      t.string   "last_name"#, null: false
      t.string   "github_username"#, null: false
      t.string   "avatar_url"
      t.datetime "last_login_at"
      t.datetime "last_logout_at"
      t.datetime "last_activity_at"
      t.string   "last_login_from_ip_address"
      t.datetime "lock_expires_at"
      t.integer  "failed_logins_count"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    end

    create_table :authentications do |t|
      t.integer :user_id, null: false
      t.string :provider, :uid, null: false
    
      t.timestamps
    end
    add_index :authentications, :user_id

  end
end
