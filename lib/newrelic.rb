class Newrelic
  class << self
    def account
      @@account ||= NewRelicApi::Account.first
    end

    mattr_accessor :application_name

    def application
      @@application ||= account.applications.detect { |a| a.name.downcase == application_name.downcase }
    end

    def nr_get(url)
      response = Curl::Easy.perform(url) do |curl|
        curl.headers["x-api-key"] = NewRelicApi.api_key
      end
      response.body_str
    end

    def get_json(url)
      response = nr_get(url)
      JSON.parse(response) unless response.blank?
    end

    def get_servers(app=nil)
      if app
        get_json("#{app.servers_url}.json")
      else
        get_json(servers_url)
      end
    end

    def get_metrics(agent_id)
      get_json("https://api.newrelic.com/api/v1/agents/#{agent_id}/metrics.json")
    end

    def servers_url
      "https://api.newrelic.com/api/v1/accounts/#{account.id}/servers.json"
    end
  end
end
