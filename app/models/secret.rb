class Secret < ActiveRecord::Base
  attr_accessible :receiver_id, :content
end
