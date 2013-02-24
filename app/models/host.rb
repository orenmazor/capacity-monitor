class Host < ActiveRecord::Base
  attr_accessible :agent_id, :fetched_at, :hostname
end
