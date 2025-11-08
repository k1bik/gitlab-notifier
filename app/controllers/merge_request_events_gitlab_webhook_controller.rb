class MergeRequestEventsGitlabWebhookController < ApplicationController
  def create
    Setting.observable_labels.each do |label_name|
      if label_added?(label_name)
        send_notification(label_name)
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

    Slack::SendDmMessageJob.perform_async(author_email, text)
  end

  def label_added?(label_name)
    current_labels.any? { it["title"] == label_name } && previous_labels.none? { it["title"] == label_name }
  end

  def current_labels = params.dig("changes", "labels", "current") || []

  def previous_labels = params.dig("changes", "labels", "previous") || []
end
