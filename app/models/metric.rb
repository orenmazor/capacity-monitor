class Metric < ActiveRecord::Base
  belongs_to :agent
  has_many :samples
end
