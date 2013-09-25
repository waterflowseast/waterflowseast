class Secret < ActiveRecord::Base
  attr_accessible :receiver_id, :content
  
  belongs_to :sender, class_name: :User
  belongs_to :receiver, class_name: :User

  validates :sender_id, presence: true
  validates :receiver_id, presence: true
  validates :content, presence: true, length: { minimum: EXTRA_CONFIG['secret_content_min'] }
  
  default_scope order: 'secrets.created_at DESC'

  def points_cost
    return 0 if receiver.has_followed? sender
    POINTS_CONFIG['send_secret'].abs
  end
end
