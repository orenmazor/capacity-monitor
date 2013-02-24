
namespace :newrelic do
  desc "fetch server list from newrelic"
  task :fetch_servers => [:environment] do
    begin
      data = JSON.load(`curl -gH "x-api-key:#{ENV['NEWRELIC_API_KEY']}"  https://api.newrelic.com/api/v1/accounts/12/servers.json 2>/dev/null`)
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

    $stdout.puts "Imported the current hosts form newrelic"


  end
end
