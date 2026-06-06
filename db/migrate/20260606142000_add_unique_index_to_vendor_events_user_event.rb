class AddUniqueIndexToVendorEventsUserEvent < ActiveRecord::Migration[7.1]
  def change
    add_index :vendor_events, [:user_id, :event_id], unique: true, name: "index_vendor_events_on_user_id_and_event_id"
  end
end
