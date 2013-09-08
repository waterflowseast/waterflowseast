class Post < ActiveRecord::Base
  attr_accessible :title, :content, :extra_info, :node_id

  has_many :collecting_relationships, dependent: :destroy
  has_many :collectors, through: :collecting_relationships, source: :user
  
  has_many :voting_up_relationships, as: :votable, dependent: :destroy
  has_many :up_voters, through: :voting_up_relationships, source: :user

  has_many :voting_down_relationships, as: :votable, dependent: :destroy
  has_many :down_voters, through: :voting_down_relationships, source: :user
  
  default_scope order: 'posts.updated_at DESC'

  def points_cost
    return 0 if node.node_group.in? NodeGroup.technicals
    return 0 if node.in? Node.children
    POINTS_CONFIG['non_technical_post'].abs
  end

  def points_bonus_for_collecting
    case collectors_count
    when POINTS_CONFIG['level_1_number']
      POINTS_CONFIG['be_collected_level_1_points']
    when POINTS_CONFIG['level_2_number']
      POINTS_CONFIG['be_collected_level_2_points']
    when POINTS_CONFIG['level_3_number']
      POINTS_CONFIG['be_collected_level_3_points']
    else
      0
    end
  end

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
