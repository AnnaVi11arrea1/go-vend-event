class AddCityToVendorEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :city, :string
  end
end
