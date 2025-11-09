class AddTextToTemporaryDeploymentNotificationTarget < ActiveRecord::Migration[8.0]
  def change
    add_column :temporary_deployment_notification_targets, :text, :string
  end
end
