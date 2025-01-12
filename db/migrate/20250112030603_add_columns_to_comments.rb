class AddColumnsToComments < ActiveRecord::Migration[7.1]
  def change
    add_column :comments, :body, :text 
    add_column :comments, :author_id, :bigint, null: false
    add_column :comments, :event_id, :bigint, null: false

    add_foreign_key :comments, :users, column: :author_id
    add_foreign_key :comments, :events, column: :event_id
  end
end
