class AddStartsAtToVendorEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :starts_at, :datetime
  end
end
