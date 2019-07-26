class CreateUsers2 < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :github_login
      t.string :github_avatar_url
      t.timestamps
      t.index :github_login, unique: true
    end
  end
end
