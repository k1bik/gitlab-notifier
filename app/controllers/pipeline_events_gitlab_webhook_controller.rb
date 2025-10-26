class PipelineEventsGitlabWebhookController < ApplicationController
  def create
    return unless pipeline_event?

    builds = params.dig("builds")
    deploy_build = builds.find { |build| build.dig("stage") == "deploy" }

    return if deploy_build.blank?

    environment = deploy_build.dig("environment", "name")
    status = deploy_build.dig("status")
    gitlab_user_id = params.dig("user", "id")
    pipeline_url = params.dig("object_attributes", "url")
    commit_url = params.dig("commit", "url")
    commit_title = params.dig("commit", "title")

    if environment.blank? || status.blank? || gitlab_user_id.blank? || pipeline_url.blank? || commit_url.blank? || commit_title.blank?
      raise "Environment, status, gitlab_user_id, pipeline_url, commit_url, and commit_title are required"
    end

    if (user_mapping = UserMapping.find_by(gitlab_id: gitlab_user_id)).present?
      text = case status
      when "running"
        "🚀 <#{commit_url}|#{commit_title}> deploy to <#{pipeline_url}|#{environment}> is starting..."
      when "success"
        "✅ <#{commit_url}|#{commit_title}> deploy to <#{pipeline_url}|#{environment}> completed successfully!"
      when "canceled"
        "🚫 <#{commit_url}|#{commit_title}> deploy to <#{pipeline_url}|#{environment}> was canceled"
      when "failed"
        "🟥 <#{commit_url}|#{commit_title}> deploy to <#{pipeline_url}|#{environment}> failed"
      end

      Slack::SendDmMessageJob.perform_async(user_mapping.email, text)
    end
  end

  private

  def pipeline_event?
    params.dig("object_kind") == "pipeline"
  end
end
