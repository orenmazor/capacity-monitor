class Run < ActiveRecord::Base
  attr_accessible :begin, :end, :failures

  has_many :samples
end
