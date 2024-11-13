class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :username
      t.string :first_name
      t.string :last_name
      t.string :social_media
      t.string :email
      t.string :password
      t.text :about
      t.string :avatar

      t.timestamps
    end
  end
end
