require 'yaml'

class MetricRules
  def self.rules
    @@rules ||= YAML.load(File.read(Rails.root + 'config/rules.yml'))
  end

  def self.match?(metric)
    debugger
    self.rules.detect { |r| metric =~ /#{r["pattern"]}/ }
  end
end
