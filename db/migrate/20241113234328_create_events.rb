class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.date :application_due_at
      t.date :started_at
      t.string :information
      t.string :application_link
      t.string :tags
      t.string :address
      t.integer :host_id

      t.timestamps
    end
  end
end
