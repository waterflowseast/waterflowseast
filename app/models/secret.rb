class Secret < ActiveRecord::Base
  attr_accessible :receiver_id, :content
  
  belongs_to :sender, class_name: :User
  belongs_to :receiver, class_name: :User

  default_scope order: 'secrets.created_at DESC'

  def points_cost
    return 0 if receiver.has_followed? sender
    POINTS_CONFIG['send_secret'].abs
  end
end
