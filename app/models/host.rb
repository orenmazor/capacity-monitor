class Host < ActiveRecord::Base
  attr_accessible :agent_id, :fetched_at, :hostname

  has_many :metrics

  def self.rules
    @@rules ||= YAML.load(File.read(Rails.root + 'config/host_rules.yml'))
  end

  def self.match?(host)
    self.rules.detect { |r| host =~ /#{r["pattern"]}/ }
  end
end
