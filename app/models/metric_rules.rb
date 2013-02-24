require 'yaml'

class MetricRules
  def self.rules
    @@rules ||= YAML.load(File.read(Rails.root + 'config/rules.yml'))
  end

  def self.match?(host, metric)
    self.rules.detect { |r| host =~ /#{r["host"]}/ && metric =~ /#{r["pattern"]}/ }
  end

  def self.match_host?(host)
    self.rules.detect { |r| host =~ /#{r["host"]}/ }
  end

end
