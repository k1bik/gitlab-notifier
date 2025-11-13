class MergeRequestEventsGitlabWebhookController < ApplicationController
  def create
    action = params.dig("object_attributes", "action")
    source_branch = params.dig("object_attributes", "source_branch")

    if (slack_channel_id = ENV["SLACK_DEV_CHANNEL_ID"]).present? && source_branch.match?(/\Arelease\/rc-\d+\z/)
      text = case action
      when "merge"
        "🎉 Release branch *#{source_branch}* successfully merged! 🚀 If you have any tasks that still need to go into this release, please change the target branch of their merge requests to *master*"
      when "open"
        "🚀 New release branch *#{source_branch}* is ready! If you have any open merge requests for this release, change their target branch to *#{source_branch}*"
      end

      if text.present?
        Slack::SendDmMessageJob.perform_async(slack_channel_id, text)
      end
    end

    Setting.observable_labels.each do |label_name|
      if label_added?(label_name)
        send_notification(label_name)
      end
    end

    detailed_merge_status = params.dig("object_attributes", "detailed_merge_status")
    project_id = params.dig("project", "id")
    merge_request_iid = params.dig("object_attributes", "iid")
    current_labels_titles = current_labels.pluck("title")

    if detailed_merge_status == "conflict" && current_labels_titles.exclude?("Need Rebase")
      Gitlab::Service.new.update_merge_request(project_id, merge_request_iid) do |params|
        params[:labels] = (current_labels_titles << "Need Rebase").join(",")
      end
    end
  end

  private

  def send_notification(label_name)
    author_email = params.dig("object_attributes", "last_commit", "author", "email")
    merge_request_iid = params.dig("object_attributes", "iid")
    project_url = params.dig("project", "web_url")
    merge_request_title = params.dig("object_attributes", "title")
    merge_request_url = "#{project_url}/merge_requests/#{merge_request_iid}"
    text = "🏷️ *#{label_name}* label was added to <#{merge_request_url}|#{merge_request_title}>"

    if (user_mapping = UserMapping.find_by(email: author_email)).present?
      Slack::SendDmMessageJob.perform_async(user_mapping.slack_channel_id, text)
    end
  end

  def label_added?(label_name)
    current_labels.any? { it["title"] == label_name } && previous_labels.none? { it["title"] == label_name }
  end

  def current_labels = params.dig("changes", "labels", "current") || []

  def previous_labels = params.dig("changes", "labels", "previous") || []
end
