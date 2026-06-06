class CreateTickets < ActiveRecord::Migration[7.1]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :subject, null: false
      t.text :message, null: false
      t.integer :status, null: false, default: 0
      t.text :admin_response
      t.references :responded_by, foreign_key: { to_table: :users }
      t.datetime :responded_at

      t.timestamps
    end

    add_index :tickets, :status
    add_index :tickets, :created_at
  end
end
