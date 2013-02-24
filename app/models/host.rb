class Host < ActiveRecord::Base
  attr_accessible :agent_id, :fetched_at, :hostname

  has_many :metrics

  def self.rules
    @@rules ||= YAML.load(File.read(Rails.root + 'config/host_rules.yml'))
  end

  def self.match?(host)
    self.rules.detect { |r| host =~ /#{r["pattern"]}/ }
  end

  def fetch_metrics
    metric_list = Newrelic.get_metrics(id)
    metric_list.find_all { |m| MetricRules.match?(m) }
  end

  def sync_metrics
    metric_list = fetch_metrics
    metric_list.each do |metric|
      unless Metric.find_by_host_id_and_name(id, metric['name'])
        rule = MetricRules.match?(metric)
        record = NewrelicMetric.new
        record.name = metric["name"]
        record.host_id = id
        record.field = rule["field"]
        if rule.has_key? 'maximum'
          record.maximum = rule['maximum']
        end
        record.save
      end
    end
  end
end


