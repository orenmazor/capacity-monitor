namespace :predictions do
  desc "fit curves to the metric samples"
  task :predict => [:environment] do
    values_and_run_ids = FactSample.find_latest_values_and_run_ids_per_bucket

    Metric.find_each do |metric|
      metric.curve_fit(values_and_run_ids)
      metric.save!
    end
  end
end
