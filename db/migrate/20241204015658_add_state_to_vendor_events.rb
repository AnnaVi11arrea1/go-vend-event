class AddStateToVendorEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :state, :string
  end
end
