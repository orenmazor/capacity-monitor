namespace :summary do
  task :generate => [:environment] do
    generate_summary(Date.yesterday)
  end

  task :backfill => [:environment] do
    raise "Run with START=30.days.ago or similar" unless ENV["START"]

    start = eval(ENV['START'])

    start = start.to_date if start.is_a? Time

    while start < Date.today
      generate_summary(start)
      start += 1.day
    end
  end

  def generate_summary(day)
    Summary.where(:date => day).delete_all

    summary = Summary.new
    summary.date = day
    summary.summary = Oracle.summary(day).to_json
    summary.save!
    puts "Generated summary for #{day}"
  end

end
