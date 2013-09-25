class Post < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :title, :content, :extra_info, :node_id

  belongs_to :user
  belongs_to :node

  has_many :comments, as: :commentable, dependent: :destroy

  has_many :collecting_relationships, dependent: :destroy
  has_many :collectors, through: :collecting_relationships, source: :user
  
  has_many :voting_up_relationships, as: :votable, dependent: :destroy
  has_many :up_voters, through: :voting_up_relationships, source: :user

  has_many :voting_down_relationships, as: :votable, dependent: :destroy
  has_many :down_voters, through: :voting_down_relationships, source: :user

  validates :title, presence: true, length: { minimum: EXTRA_CONFIG['post_title_min'], maximum: EXTRA_CONFIG['post_title_max'] }
  validates :content, presence: true, length: { minimum: EXTRA_CONFIG['post_content_min'] }
  validates :extra_info, length: { minimum: EXTRA_CONFIG['post_extra_info_min'] }, if: ->(post) { ! post.extra_info.nil? }
  validates :user_id, presence: true
  validates :node_id, presence: true, inclusion: { in: Node.pluck(:id) }

  before_create { generate_token :permalink }

  default_scope order: 'posts.updated_at DESC'

  def to_param
    permalink
  end

  def self.find(id)
    find_by_permalink(id)
  end

  def self.select_time(time)
    case time
    when 'today'
      where('updated_at > ?', Time.zone.now.beginning_of_day).order('posts.updated_at DESC')
    when 'three_days'
      where('updated_at > ?', 2.days.ago.beginning_of_day).order('posts.updated_at DESC')
    when 'a_week'
      where('updated_at > ?', 6.days.ago.beginning_of_day).order('posts.updated_at DESC')
    else
      scoped
    end
  end

  def self.select_hot(hot)
    case hot
    when 'collectors'
      where('collectors_count > ?', EXTRA_CONFIG['collectors_limit']).order('posts.collectors_count DESC')
    when 'up_voters'
      where('up_voters_count > ?', EXTRA_CONFIG['up_voters_limit']).order('posts.up_voters_count DESC')
    when 'comments'
      where('total_comments_count > ?', EXTRA_CONFIG['total_comments_limit']).order('posts.total_comments_count DESC')
    else
      scoped
    end
  end

  def self.select_node_group(node_group)
    found = NodeGroup.find node_group

    if found
      where node_id: found.nodes.pluck(:id)
    else
      scoped
    end
  end

  def self.select_node(node)
    found = Node.find node

    if found
      where node_id: found.id
    else
      scoped
    end
  end

  def points_cost
    # if user manually changes the node_id to a non-exist node (maybe to test whether this web app is strong or not),
    # we do nothing here, let the database do the check (through inclusion validation)
    return 0 if node.nil?

    return 0 if node.node_group.in? NodeGroup.technicals
    return 0 if node.in? Node.children
    POINTS_CONFIG['non_technical_post'].abs
  end

  def points_changed
    return 0 if node.node_group.in? NodeGroup.technicals
    return POINTS_CONFIG['children_post'] if node.in? Node.children
    POINTS_CONFIG['non_technical_post']
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

  def original_post
    self
  end

  def sub_comments
    comments.map do |comment; result|
      result = [comment]
      result << comment.sub_comments if comment.total_comments_count > 0
      result
    end.flatten
  end

  def cleared_by(deleter)
    up_voters.each do |u|
      u.increment! :points_count, POINTS_CONFIG['up_voter_compensation']
      u.receive_message POINTS_CONFIG['up_voter_compensation'], u.points_count, I18n.t('controller.post.message.up_voter_compensation', nickname: user.nickname)
      u.decrement! :up_votes_count
    end

    down_voters.each do |u|
      u.increment! :points_count, POINTS_CONFIG['down_voter_compensation']
      u.receive_message POINTS_CONFIG['down_voter_compensation'], u.points_count, I18n.t('controller.post.message.down_voter_compensation', nickname: user.nickname)
      u.decrement! :down_votes_count
    end

    collectors.each do |u|
      u.increment! :points_count, POINTS_CONFIG['collector_compensation']
      u.receive_message POINTS_CONFIG['collector_compensation'], u.points_count, I18n.t('controller.post.message.collector_compensation', nickname: user.nickname)
      u.decrement! :collections_count
    end

    if user == deleter
      user.increment! :points_count, POINTS_CONFIG['delete_post']
      user.receive_message POINTS_CONFIG['delete_post'], user.points_count, I18n.t('controller.post.message.delete_by_self', title: title)
    else
      user.receive_message 0, user.points_count, I18n.t('controller.post.message.delete_by_admin', admin: deleter.nickname, title: title)
    end

    user.decrement! :posts_count
  end
end
