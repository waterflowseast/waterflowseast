class VotingDownRelationship < ActiveRecord::Base
  attr_accessible :votable

  belongs_to :votable, polymorphic: true
  belongs_to :user

  validates :votable_id, presence: true
  validates :votable_type, presence: true
  validates :user_id, presence: true
end
