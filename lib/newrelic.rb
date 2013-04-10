require 'xmlsimple'

class Newrelic
  class << self
    def account
      @@account ||= begin
                      NewRelicApi::Account.first
                    rescue
                      nil
                    end
    end

    mattr_accessor :application_name

    def application
      @@application ||= account.applications.detect { |a| a.name.downcase == application_name.downcase }
    end

    def nr_get(url)
      begin
        uri = URI(url)
        req = Net::HTTP::Get.new(url)
        req['x-api-key'] = NewRelicApi.api_key

        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        res = http.request(req)
        res.body
      end
    end

    def get_json(url)
      Rails.logger.info("Calling newrelic json #{url}")
      response = nr_get(url)
      Rails.logger.info("Newrelic response #{response}")
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

    def get_threshold_values(agent_id)
      body = nr_get("https://api.newrelic.com/api/v1/accounts/#{account.id}/applications/#{agent_id}/threshold_values.xml")
      doc = XmlSimple.xml_in(body)
      doc["threshold_value"]
    end

    def get_value(agent_ids, metrics, field, start=(Time.now.utc-20.minutes).iso8601(0), finish=(Time.now.utc-10.minutes).iso8601(0))
      agent_ids = [agent_ids] unless agent_ids.is_a?(Array)
      metrics = [metrics] unless metrics.is_a?(Array)

      agent_string = agent_ids.map { |r| "agent_id[]=#{r}" }.join('&')
      metric_string = metrics.map { |r| "metrics[]=#{URI.encode(r)}" }.join('&')
      Newrelic.get_json("https://api.newrelic.com/api/v1/accounts/#{account.id}/metrics/data.json?#{agent_string}&#{metric_string}&field=#{field}&summary=1&begin=#{start}&end=#{finish}")
    end

    def servers_url
      "https://api.newrelic.com/api/v1/accounts/#{account.id}/servers.json"
    end
  end
end
