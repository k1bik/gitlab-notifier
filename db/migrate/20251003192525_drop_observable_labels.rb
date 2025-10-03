class DropObservableLabels < ActiveRecord::Migration[8.0]
  def change
    drop_table :observable_labels
  end
end
