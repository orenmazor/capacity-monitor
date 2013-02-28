raise "Please set ENV['STATSD_URL']" unless ENV['STATSD_URL']
raise "Please set ENV['STATSD_USER']" unless ENV['STATSD_USER']
raise "Please set ENV['STATSD_PASS']" unless ENV['STATSD_PASS']

StatsD.url = ENV['STATSD_URL']
StatsD.user = ENV['STATSD_USER']
StatsD.password = ENV['STATSD_PASS']

