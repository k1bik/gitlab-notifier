class CreateTemporaryDeploymentNotificationTargets < ActiveRecord::Migration[8.0]
  def change
    create_table :temporary_deployment_notification_targets do |t|
      t.string :environment, null: false
      t.string :slack_channel_id, null: false

      t.timestamps
    end
  end
end
