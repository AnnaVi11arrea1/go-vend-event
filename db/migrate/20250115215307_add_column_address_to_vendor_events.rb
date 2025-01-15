class AddColumnAddressToVendorEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :address, :string
  end
end
