class DeploymentEventsGitlabWebhookController < ApplicationController
  def create
    environment = params.dig("environment")
    status = params.dig("status")
    gitlab_user_id = params.dig("user", "id")
    deployable_url = params.dig("deployable_url")
    commit_url = params.dig("commit_url")
    commit_title = params.dig("commit_title")

    if (user_mapping = UserMapping.find_by(gitlab_id: gitlab_user_id)).present?
      text = {
        "running"  => "🚀 Deployment of <#{commit_url}|#{commit_title}> to <#{deployable_url}|#{environment}> has started — fingers crossed 🤞",
        "success"  => "✅ <#{commit_url}|#{commit_title}> was successfully deployed to <#{deployable_url}|#{environment}> — great job! 🎉",
        "canceled" => "⚪️ Deployment of <#{commit_url}|#{commit_title}> to <#{deployable_url}|#{environment}> was canceled — maybe later ⏸️",
        "failed"   => "❌ Deployment of <#{commit_url}|#{commit_title}> to <#{deployable_url}|#{environment}> didn’t go as planned 😞 — check the logs 🧾"
      }[status]

      return if text.blank?

      TemporaryDeploymentNotificationTarget.where(environment:).find_each do |target|
        next if status != "success"

        Slack::SendDmMessageJob.perform_async(target.slack_channel_id, target.text || text)

        target.destroy!
      end

      Slack::SendDmMessageJob.perform_async(user_mapping.slack_channel_id, text)
    end
  end
end
