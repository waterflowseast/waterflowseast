class Message < ActiveRecord::Base
  belongs_to :user

  validates :changed_points, presence: true
  validates :current_points, presence: true
  validates :content, presence: true
  
  default_scope order: 'messages.created_at DESC'

  def changed_points_display
    (changed_points > 0) ? "+#{changed_points}" : "#{changed_points}"
  end
end
