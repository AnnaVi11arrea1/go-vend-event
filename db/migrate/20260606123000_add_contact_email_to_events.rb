class AddContactEmailToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :contact_email, :string
  end
end
