class AddCityAndStateToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :city, :string
    add_column :events, :state, :string
  end
end
