class VotingDownRelationship < ActiveRecord::Base
  attr_accessible :votable_id, :votable_type
end
