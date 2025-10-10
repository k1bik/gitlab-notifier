class InteractiveMessagesSlackWebhookController < ApplicationController
  def create
    parsed_params = JSON.parse(params.to_unsafe_h["payload"])

    user_slack_id = parsed_params["user"]["id"]
    user_action = parsed_params["actions"][0]
    mark = user_action["selected_option"]["value"]
    estimation_item_id = user_action["action_id"]

    user_mapping = UserMapping.find_by!(slack_user_id: user_slack_id)
    estimation_item = EstimationItem.find(estimation_item_id)
    estimation = Estimation.find_by!(user_mapping:, estimation_item:)

    ActiveRecord::Base.transaction do
      estimation.update!(value: mark)

      if !estimation_item.results_sent && estimation_item.reload.estimations.all?(&:value)
        EstimationItems::Service.new.send_results(estimation_item)
      end
    end
  end
end
