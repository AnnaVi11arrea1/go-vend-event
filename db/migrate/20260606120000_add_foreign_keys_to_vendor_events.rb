class AddForeignKeysToVendorEvents < ActiveRecord::Migration[7.1]
  def up
    # Remove invalid rows before enforcing constraints.
    execute <<~SQL
      DELETE FROM vendor_events
      WHERE event_id IS NULL OR user_id IS NULL
    SQL

    add_index :vendor_events, :event_id unless index_exists?(:vendor_events, :event_id)
    add_index :vendor_events, :user_id unless index_exists?(:vendor_events, :user_id)

    change_column_null :vendor_events, :event_id, false
    change_column_null :vendor_events, :user_id, false

    add_foreign_key :vendor_events, :events, column: :event_id, on_delete: :cascade unless foreign_key_exists?(:vendor_events, :events, column: :event_id)
    add_foreign_key :vendor_events, :users, column: :user_id, on_delete: :cascade unless foreign_key_exists?(:vendor_events, :users, column: :user_id)
  end

  def down
    remove_foreign_key :vendor_events, column: :event_id if foreign_key_exists?(:vendor_events, :events, column: :event_id)
    remove_foreign_key :vendor_events, column: :user_id if foreign_key_exists?(:vendor_events, :users, column: :user_id)

    change_column_null :vendor_events, :event_id, true
    change_column_null :vendor_events, :user_id, true

    remove_index :vendor_events, :event_id if index_exists?(:vendor_events, :event_id)
    remove_index :vendor_events, :user_id if index_exists?(:vendor_events, :user_id)
  end
end
