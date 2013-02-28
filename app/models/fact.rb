class Fact < ActiveRecord::Base
  has_many :samples, :as => :owner

end
