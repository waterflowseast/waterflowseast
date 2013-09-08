class CollectingRelationship < ActiveRecord::Base
  attr_accessible :post_id

  belongs_to :post
  belongs_to :user

  validates :post_id, presence: true
  validates :user_id, presence: true
end
