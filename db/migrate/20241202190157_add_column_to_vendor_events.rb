class AddColumnToVendorEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :expense, :float
    add_column :vendor_events, :sales, :float
    add_column :vendor_events, :profit, :float
    add_column :vendor_events, :return, :float
  end
end
