class DropPgSearchDocuments < ActiveRecord::Migration[6.0]
  def up
    drop_table :pg_search_documents
  end

  def down
    create_table :pg_search_documents do |t|
      t.text :content
      t.belongs_to :searchable, :polymorphic => true, :index => true
      t.timestamps null: false
    end
  end
end
