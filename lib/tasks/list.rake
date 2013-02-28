
namespace :newrelic do
  desc "list hosts from newrelic"
  task :list_hosts => [:environment] do
    servers = Newrelic.get_servers
    puts "agent id\t\thostname"
    servers.each do |s|
      puts "#{s["id"]}\t\t#{s["hostname"]}"
    end
  end

  def print_metrics(agent_id)
    metrics = Newrelic.get_metrics(agent_id)
    puts "Metric\t\t\tAvailable Fields"
    metrics.each do |m|
      puts "#{m["name"]}\t\t\t#{m["fields"].join(", ")}"
    end
  end

  desc "list host metrics from newrelic"
  task :list_metrics => [:environment] do
    agent = ENV["AGENT"] || Newrelic.get_servers.first["id"]
    puts "Listing metrics for #{agent}"
    print_metrics(agent)
  end

  desc "list application metrics from newrelic"
  task :list_app_metrics => [:environment] do
    print_metrics(Newrelic.application.id)
  end

  desc "Get all field/value for an agent and metric"
  task :get => [:environment] do
    raise "set ENV['AGENT'] to the agent ID" unless ENV['AGENT']
    raise "set ENV['METRIC'] to the metric name" unless ENV['METRIC']

    agent = ENV['AGENT']
    name = ENV['METRIC']

    metrics = Newrelic.get_metrics(ENV['AGENT'])
    metric = metrics.detect { |m| m["name"] =~ /#{name}/ }

    if metric.nil?
      puts "That metric doesn't exist"
      return
    end

    puts "Fields and values for #{name} on agent #{agent}"
    metric["fields"].each do |f|
      value = Newrelic.get_value(agent, metric["name"], f)
      puts "\t#{f}\t\t\t#{value[0][f]}"
    end
  end
end

