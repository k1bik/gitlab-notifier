class CreateEstimationItems < ActiveRecord::Migration[8.0]
  def change
    create_table :estimation_items do |t|
      t.string :reference_url, null: false
      t.boolean :results_sent, null: false, default: false, comment: "Whether the results have been sent to the users"

      t.timestamps
    end

    create_table :estimations do |t|
      t.references :user_mapping, null: false, foreign_key: true
      t.references :estimation_item, null: false, foreign_key: true
      t.string :value

      t.timestamps
    end

    add_index :estimations, [:user_mapping_id, :estimation_item_id], unique: true
  end
end
