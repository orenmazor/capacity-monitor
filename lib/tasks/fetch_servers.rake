AGENT_DELETE_THRESHOLD=0.9

namespace :newrelic do
  desc "fetch server list from newrelic"
  task :fetch_servers => [:environment] do
    data = []
    begin
      data = Newrelic.get_servers
    rescue StandardError => e
      puts "Impossible to fetch the list of servers: #{e}"
    end

    seen = []
    added = 0

    Agent.transaction do

      data.each do |hash|
        if (match = Agent.match?(hash['hostname'])) && !Agent.exists?(:newrelic_id => hash['id']) && hash['id'].to_i != 0
          agent = Agent.new(hostname: hash['hostname'])
          agent.newrelic_id = hash['id']
          agent.role = match['role']
          agent.save
          added += 1
        end
        seen << hash['id']
      end

      if seen.count > Agent.count * AGENT_DELETE_THRESHOLD
        to_delete = Agent.where(["newrelic_id NOT IN (?)", seen])
        to_delete.each do |agent|
          puts "Deleting agent ID #{agent.id} - newrelic ID #{agent.newrelic_id}"
          agent.destroy
        end
      else
        puts "Newrelic returned less than #{AGENT_DELETE_THRESHOLD*100}% of existing servers, skipping delete"
      end
    end

    $stdout.puts "Imported #{added} hosts from newrelic"

    Agent.find_each do |agent|
      print "."
      agent.sync_metrics
    end
    puts ""
  end
end
