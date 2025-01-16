class AddColumnEndsAtToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :ends_at, :date
  end
end
