class CreateUserMapping < ActiveRecord::Migration[8.0]
  def change
    create_table :user_mappings do |t|
      t.string :email, null: false
      t.string :slack_user_id, null: false
      t.string :slack_channel_id, null: false
      t.timestamps
    end
  end
end
