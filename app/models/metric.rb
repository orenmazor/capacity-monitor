class Metric < ActiveRecord::Base
  belongs_to :host
  has_many :samples
end
