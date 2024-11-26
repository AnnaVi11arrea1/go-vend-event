class AddPrivateToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :private, :boolean, default: false
  end
end
