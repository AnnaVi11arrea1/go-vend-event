class RemoveAddedFromVendorEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :vendor_event, :added, :boolean
  end
end
