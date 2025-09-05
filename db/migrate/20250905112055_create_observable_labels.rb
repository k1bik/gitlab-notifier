class CreateObservableLabels < ActiveRecord::Migration[8.0]
  def change
    create_table :observable_labels do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
