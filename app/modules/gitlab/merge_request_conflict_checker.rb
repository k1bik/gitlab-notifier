module Gitlab
  class MergeRequestConflictChecker
    include Sidekiq::Job

    def perform
      gitlab_service = Gitlab::Service.new
      last_check_key = "mr_conflict_checker:last_check"
      last_check = Rails.cache.fetch(last_check_key, expires_in: 1.hour) { 15.minutes.ago }

      puts "Last check: #{last_check}"

      merge_requests = gitlab_service.get_merge_requests do |request|
        request.params["state"] = "opened"
        request.params["per_page"] = 50
        request.params["updated_after"] = last_check.iso8601
      end

      Rails.cache.write(last_check_key, Time.current)

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
