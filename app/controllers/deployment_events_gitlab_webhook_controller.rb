class DeploymentEventsGitlabWebhookController < ApplicationController
  def create
    environment = params.dig("environment")
    status = params.dig("status")
    gitlab_user_id = params.dig("user", "id")
    deployable_url = params.dig("deployable_url")
    commit_url = params.dig("commit_url")
    commit_title = params.dig("commit_title")

    if (user_mapping = UserMapping.find_by(gitlab_id: gitlab_user_id)).present?
      text = case status
      when "running"
        "🚀 Deployment of <#{commit_url}|#{commit_title}> to <#{deployable_url}|#{environment}> has started — fingers crossed 🤞"
      when "success"
        "✅ <#{commit_url}|#{commit_title}> was successfully deployed to <#{deployable_url}|#{environment}> — great job! 🎉"
      when "canceled"
        "⚪️ Deployment of <#{commit_url}|#{commit_title}> to <#{deployable_url}|#{environment}> was canceled — maybe later ⏸️"
      when "failed"
        "❌ Deployment of <#{commit_url}|#{commit_title}> to <#{deployable_url}|#{environment}> didn’t go as planned 😞 — check the logs 🧾"
      end

      Slack::SendDmMessageJob.perform_async(user_mapping.email, text)
    end
  end
end
