class DeploymentEventsGitlabWebhookController < ApplicationController
  def create
    return unless deployment_event?

    environment = params.dig("environment")
    status = params.dig("status")
    gitlab_user_id = params.dig("user", "id")
    deployable_url = params.dig("deployable_url")
    commit_url = params.dig("commit_url")
    commit_title = params.dig("commit_title")

    if environment.blank? || status.blank? || gitlab_user_id.blank? || deployable_url.blank? || commit_url.blank? || commit_title.blank?
      raise "Environment, status, gitlab_user_id, deployable_url, commit_url, and commit_title are required"
    end

    if (user_mapping = UserMapping.find_by(gitlab_id: gitlab_user_id)).present?
      text = case status
      when "running"
        "🚀 <#{commit_url}|#{commit_title}> deployment to <#{deployable_url}|#{environment}> is starting..."
      when "success"
        "✅ <#{commit_url}|#{commit_title}> deployment to <#{deployable_url}|#{environment}> completed successfully!"
      when "canceled"
        "🚫 <#{commit_url}|#{commit_title}> deployment to <#{deployable_url}|#{environment}> was canceled"
      when "failed"
        "🟥 <#{commit_url}|#{commit_title}> deployment to <#{deployable_url}|#{environment}> failed"
      end

      Slack::SendDmMessageJob.perform_async(user_mapping.email, text)
    end
  end

  private

  def deployment_event?
    params.dig("object_kind") == "deployment"
  end
end
