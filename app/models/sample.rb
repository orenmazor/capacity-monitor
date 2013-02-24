class Sample < ActiveRecord::Base
  belongs_to :metric
  attr_accessible :value
end
