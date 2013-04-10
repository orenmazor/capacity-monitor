class Sample < ActiveRecord::Base
  belongs_to :run

  attr_accessible :value, :fetched_at, :run

  def calculate_thruzero
    fact_sample = FactSample.find_by_run_id(run_id)

    if value == 0 || fact_sample.nil?
      self.thruzero = 0
      return
    end

    # calculates a prediction based on assumption metric would have 0 usage at 0 rpm
    slope = fact_sample.value / value

    # y = mx + b for x=100, b = 0
    self.thruzero = slope * 100
  end

end
