class Message < ActiveRecord::Base
  default_scope order: 'messages.created_at DESC'
  
end
