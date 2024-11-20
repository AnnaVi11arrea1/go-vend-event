class AddPhotoToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :photo, :string
  end
end
