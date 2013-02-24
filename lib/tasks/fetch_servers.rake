
namespace :newrelic do
  desc "fetch server list from newrelic"
  task :fetch_servers => [:environment] do
    begin
      data = Newrelic.get_servers
    rescue Standarderror => e
      puts "Impossible to fetch the list of servers: #{e}"
    end

    fetched_at = Time.now.utc

    Host.transaction do
      data.each do |hash|
        host = Host.new(hostname: hash['hostname'], fetched_at: fetched_at)
        host.id = hash['id']
        host.save
      end
    end

    $stdout.puts "Imported #{data.count} hosts from newrelic"

  end
end
