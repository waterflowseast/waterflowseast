class Comment < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :commentable_id, :commentable_type, :content

  has_many :voting_up_relationships, as: :votable, dependent: :destroy
  has_many :up_voters, through: :voting_up_relationships, source: :user

  has_many :voting_down_relationships, as: :votable, dependent: :destroy
  has_many :down_voters, through: :voting_down_relationships, source: :user
  
  default_scope order: 'comments.created_at ASC'

  def points_bonus_for_voting_up
    case up_voters_count
    when POINTS_CONFIG['level_1_number']
      POINTS_CONFIG['be_voted_up_level_1_points']
    when POINTS_CONFIG['level_2_number']
      POINTS_CONFIG['be_voted_up_level_2_points']
    when POINTS_CONFIG['level_3_number']
      POINTS_CONFIG['be_voted_up_level_3_points']
    else
      0
    end
  end
end
