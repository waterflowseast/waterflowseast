class Secret < ActiveRecord::Base
  attr_accessible :receiver_id, :content

  default_scope order: 'secrets.created_at DESC'
end
