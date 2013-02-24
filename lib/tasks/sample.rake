
namespace :newrelic do
  desc "sample metrics from newrelic"
  task :sample => [:environment] do
    data = []
    begin
      data = Newrelic.get_servers
    rescue StandardError => e
      puts "Impossible to fetch the list of servers: #{e}"
    end

    fetched_at = Time.now.utc
    count = 0

    Host.transaction do
      data.each do |hash|
        if match=Host.match?(hash['hostname'])
          host = Host.new(hostname: hash['hostname'], fetched_at: fetched_at)
          host.id = hash['id']
          host.role = match['role']
          host.save
          count+=1
        end
      end
    end

    $stdout.puts "Imported #{count} hosts from newrelic"
  end
end
