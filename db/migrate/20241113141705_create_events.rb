class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.date :started_at
      t.date :application_due_at
      t.text :information
      t.string :application_link
      t.string :tags
      t.text :address
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
