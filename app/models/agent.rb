class Agent < ActiveRecord::Base
  attr_accessible :agent_id, :fetched_at, :hostname

  has_many :metrics, :dependent => :destroy

  def self.rules
    @@rules ||= YAML.load(File.read(Rails.root + 'config/agent_rules.yml'))
  end

  def self.blacklist
    @@blacklist ||= YAML.load(File.read(Rails.root + 'config/agent_blacklist.yml'))
  end

  def self.match?(agent)
    rule = self.rules.detect { |r| agent =~ /#{r["pattern"]}/ } 
    return rule if rule && !self.blacklist.detect { |r| agent =~ /#{r["pattern"]}/ }
  end

  def fetch_metrics
    metric_list = Newrelic.get_metrics(newrelic_id)
    metric_list.find_all { |m| MetricRules.match?(m) }
  end

  def sync_metrics
    fetch_metrics.each do |metric|
      unless Metric.find_by_agent_id_and_name(id, metric['name'])
        rule = MetricRules.match?(metric)
        record = NewrelicMetric.new
        record.name = metric["name"]
        record.agent_id = id
        record.field = rule["field"]
        record.maximum = rule['maximum']
        record.group_name = rule['group']
        record.save
      end
    end
  end
end


