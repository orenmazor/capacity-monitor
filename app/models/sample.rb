class Sample < ActiveRecord::Base
  belongs_to :run

  attr_accessible :value, :fetched_at, :run
end
