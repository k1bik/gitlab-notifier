module Gitlab
  class MergeRequestConflictChecker
    include Sidekiq::Job

    def perform
      current_hour = Time.now.in_time_zone("Europe/Moscow").hour
      return unless current_hour.between?(9, 19)

      gitlab_service = Gitlab::Service.new

      merge_requests = gitlab_service.get_merge_requests do |request|
        request.params["state"] = "opened"
        request.params["per_page"] = 70
      end

      merge_requests.each do |merge_request|
        next if merge_request["detailed_merge_status"] != "conflict"

        labels = merge_request["labels"].dup

        next if labels.include?("Need Rebase")

        gitlab_service.update_merge_request(merge_request["iid"]) do |params|
          params[:labels] = (labels << "Need Rebase").join(",")
        end
      end
    end
  end
end
