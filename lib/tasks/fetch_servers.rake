namespace :newrelic do
  desc "fetch server list from newrelic"
  task :fetch_servers => [:environment] do
    data = []
    begin
      data = Newrelic.get_servers
    rescue StandardError => e
      puts "Impossible to fetch the list of servers: #{e}"
    end

    fetched_at = Time.now.utc
    count = 0

    Agent.transaction do
      data.each do |hash|
        if (match = Agent.match?(hash['hostname'])) && !Agent.exists?(:id => hash['id'])
          agent = Agent.new(hostname: hash['hostname'], fetched_at: fetched_at)
          agent.id = hash['id']
          agent.role = match['role']
          agent.save
          count+=1
        end
      end
    end

    $stdout.puts "Imported #{count} hosts from newrelic"
  end
end
