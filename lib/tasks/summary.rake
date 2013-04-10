namespace :summary do
  task :generate => [:environment] do
    Summary.where(:date => Date.yesterday).delete_all

    summary = Summary.new
    summary.date = Date.yesterday
    summary.summary = Oracle.summary(Date.yesterday).to_json
    summary.save!
  end

end
