module Slack
  class Service
    def send_message(email:, text:)
      user_mapping = UserMapping.find_by(email:)

      return if user_mapping.blank?

      slack_connection.post("chat.postMessage") do |request|
        request.body = { channel: user_mapping.slack_channel_id, text: }.to_json
      end
    end

    def find_user_id_by_email(email)
      response = slack_connection.get("users.lookupByEmail") do |request|
        request.params["email"] = email
      end

      handle_response(response) do |body|
        unless body["user"] && body["user"]["id"]
          raise "User not found or invalid response structure"
        end

        body["user"]["id"]
      end
    end

    def open_dm(slack_user_id)
      response = slack_connection.post("conversations.open") do |request|
        request.body = { users: slack_user_id }.to_json
      end

      handle_response(response) do |body|
        unless body["channel"] && body["channel"]["id"]
          raise "Invalid response structure: channel or channel.id not found"
        end

        body["channel"]["id"]
      end
    end

    def slack_connection
      @slack_connection ||= Faraday.new(
        url: "https://slack.com/api",
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV["SLACK_OAUTH_TOKEN"]}"
        }
      )
    end

    def handle_response(response)
      unless response.success?
        raise "HTTP error: #{response.status} - #{response.reason_phrase}"
      end

      body = JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise "Failed to parse Slack API response: #{e.message}"
    rescue Faraday::Error => e
      raise "Network error when calling Slack API: #{e.message}"
    rescue StandardError => e
      raise "Unexpected error: #{e.message}"
    else
      unless body["ok"]
        error_message = body["error"] || "Unknown error"
        raise "Slack API error: #{error_message}"
      end

      yield(body)
    end
  end
end
