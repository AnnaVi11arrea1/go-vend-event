class AddAddedToVendorEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :added, :boolean
  end
end
