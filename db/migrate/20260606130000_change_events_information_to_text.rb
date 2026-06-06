class ChangeEventsInformationToText < ActiveRecord::Migration[7.1]
  def up
    change_column :events, :information, :text
  end

  def down
    change_column :events, :information, :string
  end
end
