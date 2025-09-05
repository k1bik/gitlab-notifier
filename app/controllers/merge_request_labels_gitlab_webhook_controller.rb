class MergeRequestLabelsGitlabWebhookController < ApplicationController
  def create
    return unless merge_request_event?

    observable_labels = ObservableLabel.pluck(:name)

    observable_labels.each do |label_name|
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

    return if merge_request_iid.blank? || project_url.blank? || merge_request_title.blank? || author_email.blank?

    merge_request_url = "#{project_url}/merge_requests/#{merge_request_iid}"
    text = "*#{label_name}* label was added to the <#{merge_request_url}|#{merge_request_title}>"

    Slack::SendDmMessageJob.perform_async(author_email, text)
  end

  def current_labels = params.dig("changes", "labels", "current") || []

  def previous_labels = params.dig("changes", "labels", "previous") || []

  def label_added?(label_name)
    current_labels.any? { it["title"] == label_name } && previous_labels.none? { it["title"] == label_name }
  end

  def merge_request_event?
    params.dig("object_kind") == "merge_request" && params.dig("event_type") == "merge_request"
  end
end
