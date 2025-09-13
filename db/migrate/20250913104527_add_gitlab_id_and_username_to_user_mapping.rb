class AddGitlabIdAndUsernameToUserMapping < ActiveRecord::Migration[8.0]
  def change
    add_column :user_mappings, :gitlab_id, :string, null: false
    add_column :user_mappings, :gitlab_username, :string, null: false
  end
end
