class Sample < ActiveRecord::Base
  belongs_to :metric
  attr_accessible :value, :fetched_at
end
