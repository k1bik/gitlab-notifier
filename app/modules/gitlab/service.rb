module Gitlab
  class Service
    def find_user_id_by_username(username)
      response = connection.get("users") do |request|
        request.params["username"] = username
      end

      http_client.handle_response(response) do |body|
        users_size = body.size

        if users_size != 1
          raise "Multiple users found for username: #{username}"
        end

        body.first["id"]
      end
    end

    def username_by_email(email) = email.split("@").first

    private

    def http_client
      @http_client ||= Http::Client.new
    end

    def connection
      @connection ||= http_client.connection(
        url: ENV["GITLAB_API_URL"],
        headers: {
          "PRIVATE-TOKEN" => "#{ENV["GITLAB_ACCESS_TOKEN"]}"
        }
      )
    end
  end
end
