class ChangeStartsAtToStartTime < ActiveRecord::Migration[7.1]
  def change
    rename_column :vendor_events, :starts_at, :start_time
  end
end
