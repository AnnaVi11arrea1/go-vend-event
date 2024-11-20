class AddPhotoToVendorEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :vendor_events, :photo, :string
  end
end
