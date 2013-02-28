class Metric < ActiveRecord::Base
  belongs_to :agent

  has_many :samples

  attr_accessor :points, :prediction, :best_fit
end
