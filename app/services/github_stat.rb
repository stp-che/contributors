class GithubStat

  class Error < ::StandardError
  end

  class APIError < Error
    def initialize(data)
      data = '%s %s' % [data.code, data.message] if data.kind_of?(Net::HTTPResponse)
      super "Github API error: #{data}"
    end
  end

  class HTTPError < Error
    def initialize(msg)
      super "HTTP error: #{msg}"
    end
  end

  class << self
    # @param [String] repo_path
    # @return [GithubStat::Contributors]
    def contributors(repo_path)
      uri = URI("https://api.github.com/repos/#{repo_path}/stats/contributors")

      response = nil
      begin
        Net::HTTP.start uri.host, uri.port, use_ssl: true do |http|
          request = Net::HTTP::Get.new uri
          response = http.request request
        end
      rescue => e
        raise HTTPError.new(e.message)
      end

      Contributors.new(response)
    end
  end

  class Contributors < Array
    # @param [Net::HTTPResponse] http_response
    def initialize(http_response)
      case http_response
      when Net::HTTPOK
        @ready = true
        super JSON.parse(http_response.body).sort_by{|c| c['total']}.reverse.map{|c| c['author']['login']}
      when Net::HTTPAccepted
        @ready = false
      else
        raise APIError.new(http_response)
      end
    end

    def ready?
      @ready
    end
  end
end