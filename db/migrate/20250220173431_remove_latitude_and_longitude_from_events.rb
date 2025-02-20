class RemoveLatitudeAndLongitudeFromEvents < ActiveRecord::Migration[7.1]
  def change
    remove_column :events, :latitude, :float
    remove_column :events, :longitude, :float
  end
end
