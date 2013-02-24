raise "Please set ENV['NEWRELIC_API_KEY']" unless ENV['NEWRELIC_API_KEY']
raise "Please set ENV['NEWRELIC_APP']" unless ENV['NEWRELIC_APP']

Newrelic.application_name = ENV['NEWRELIC_APP']
NewRelicApi.api_key = ENV['NEWRELIC_API_KEY']
