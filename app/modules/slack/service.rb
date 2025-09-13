module Slack
  class Service
    def find_user_id_by_email(email)
      response = connection.get("users.lookupByEmail") do |request|
        request.params["email"] = email
      end

      http_client.handle_response(response) do |body|
        unless body["user"] && body["user"]["id"]
          raise "User not found or invalid response structure"
        end

        body["user"]["id"]
      end
    end

    def open_dm(slack_user_id)
      response = connection.post("conversations.open") do |request|
        request.body = { users: slack_user_id }.to_json
      end

      http_client.handle_response(response) do |body|
        unless body["channel"] && body["channel"]["id"]
          raise "Invalid response structure: channel or channel.id not found"
        end

        body["channel"]["id"]
      end
    end

    def send_dm(user_mapping, text)
      connection.post("chat.postMessage") do |request|
        request.body = {
          channel: user_mapping.slack_channel_id,
          text:,
          unfurl_links: false,
          unfurl_media: false
        }.to_json
      end
    end

    private

    def http_client
      @http_client ||= Http::Client.new
    end

    def connection
      @connection ||= http_client.connection(
        url: ENV["SLACK_API_URL"],
        headers: {
          "Content-Type" => "application/json",
          "Authorization" => "Bearer #{ENV["SLACK_OAUTH_TOKEN"]}"
        }
      )
    end
  end
end
