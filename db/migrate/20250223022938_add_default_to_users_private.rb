class AddDefaultToUsersPrivate < ActiveRecord::Migration[7.1]
  def change
    change_column_default :users, :private, from: nil, to: true
  end
end
