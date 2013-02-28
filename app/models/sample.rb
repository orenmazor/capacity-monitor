class Sample < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true

  attr_accessible :value, :fetched_at
end
