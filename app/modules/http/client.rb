module Http
  class Client
    def connection(**args) = Faraday.new(**args)

    def handle_response(response)
      unless response.success?
        raise "HTTP error: #{response.status} - #{response.reason_phrase}"
      end

      body = JSON.parse(response.body)
    rescue JSON::ParserError => e
      raise "Failed to parse response: #{e.message}"
    rescue Faraday::Error => e
      raise "Network error: #{e.message}"
    rescue StandardError => e
      raise "Unexpected error: #{e.message}"
    else
      yield(body)
    end
  end
end
