class AddColumnDescriptionToVendorEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :description, :text
  end
end
