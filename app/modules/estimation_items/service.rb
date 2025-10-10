module EstimationItems
  class Service
    def create_estimation_item(reference_url, emails)
      ActiveRecord::Base.transaction do
        user_mappings_ids = UserMapping.where(email: emails).pluck(:id)

        if user_mappings_ids.blank?
          raise ActiveRecord::RecordNotFound, "No user mappings found for the given emails"
        end

        estimation_item = EstimationItem.create!(reference_url:)
        estimation_item_id = estimation_item.id
        estimations = user_mappings_ids.map { { user_mapping_id: it, estimation_item_id: } }

        Estimation.insert_all(estimations)

        estimation_item
      end
    end

    def send_results(estimation_item)
      estimations = estimation_item.estimations.includes(:user_mapping).order(value: :asc)

      if estimations.blank?
        raise "No estimations found"
      end

      # Helper method to build cells in table
      build_cell = ->(text, bold = false) do
        {
          "type": "rich_text",
          "elements": [
            {
              "type": "rich_text_section",
              "elements": [
                {
                  "type": "text",
                  "text": text.to_s,
                  "style": { bold: }
                }.compact
              ]
            }
          ]
        }
      end

      blocks = [
        {
          "type": "section",
          "text": {
            "type": "mrkdwn",
            "text": "🕵🏼‍♂️ *Estimation results* ➜ #{estimation_item.reference_url}"
          }
        },
        {
          "type": "table",
          "rows": [
            [build_cell.call("Employee", true), build_cell.call("Estimate", true)], # header
            *estimations.map do |estimation|
              [build_cell.call(estimation.user_mapping.email), build_cell.call(estimation.value.presence || "Not estimated 😢")]
            end
          ]
        }
      ]

      ActiveRecord::Base.transaction do
        slack_service = Slack::Service.new

        estimations.each do |estimation|
          slack_service.send_dm(estimation.user_mapping, nil, blocks)
        end
        estimation_item.update!(results_sent: true)
      end
    end

    def send_estimations(estimation_item)
      if (estimation_marks = Setting.estimation_marks).blank?
        raise "Estimation marks are not set"
      end

      user_mappings = UserMapping.joins(:estimations).where(estimations: { estimation_item_id: estimation_item.id })
      if user_mappings.blank?
        raise "User mappings are not set"
      end

      slack_service = Slack::Service.new
      estimation_item_id = estimation_item.id.to_s # to_s is required for action_id
      options = estimation_marks.map do |mark|
        { "text" => { "type" => "plain_text", "text" => mark.to_s }, "value" => mark.to_s }
      end

      user_mappings.each do |user_mapping|
        blocks = [
          {
            "type": "section",
            "text": {
              "type": "mrkdwn",
              "text": "Hey, *#{user_mapping.email}* 👋\nHow many hours do you think you will need for this task? 🤔\n #{estimation_item.reference_url}"
            },
            "accessory": {
              "type": "radio_buttons",
              "options": options,
              "action_id": estimation_item_id
            }
          }
        ]

        slack_service.send_dm(user_mapping, nil, blocks)
      end
    end
  end
end
