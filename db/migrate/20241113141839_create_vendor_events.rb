class CreateVendorEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :vendor_events do |t|
      t.integer :event_id
      t.string :application_status
      t.boolean :paid
      t.integer :user_id

      t.timestamps
    end
  end
end
