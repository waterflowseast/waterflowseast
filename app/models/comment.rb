class Comment < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :commentable, :content

  belongs_to :commentable, polymorphic: true, touch: true
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :voting_up_relationships, as: :votable, dependent: :destroy
  has_many :up_voters, through: :voting_up_relationships, source: :user

  has_many :voting_down_relationships, as: :votable, dependent: :destroy
  has_many :down_voters, through: :voting_down_relationships, source: :user

  validates :commentable_id, presence: true
  validates :commentable_type, presence: true
  validates :content, presence: true, length: { minimum: EXTRA_CONFIG['comment_content_min'] }
  validates :user_id, presence: true

  before_create { generate_token :permalink }
  before_create :generate_floor

  default_scope order: 'comments.created_at ASC'

  def to_param
    permalink
  end

  def self.find(id)
    find_by_permalink(id)
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
    ancestors.last    
  end

  def ancestors
    comment_ancestor = self
    comment_ancestors = []

    begin
      comment_ancestor = comment_ancestor.commentable
      comment_ancestors << comment_ancestor
    end while comment_ancestor.instance_of? Comment

    comment_ancestors
  end

  def too_deep?
    ancestors.size > EXTRA_CONFIG['nested_level_max']
  end

  def sub_comments
    comments.map do |comment; result|
      result = [comment]
      result << comment.sub_comments if comment.total_comments_count > 0
      result
    end.flatten
  end

  def compensate_from(comment_or_post)
    type = comment_or_post.instance_of?(Comment) ? I18n.t('controller.comment.is_comment') : I18n.t('controller.comment.is_post')
    comment_or_post_user = comment_or_post.user

    up_voters.each do |u|
      if u != comment_or_post_user
        u.increment! :points_count, POINTS_CONFIG['up_voter_compensation']
        u.receive_message POINTS_CONFIG['up_voter_compensation'], u.points_count, I18n.t('controller.comment.message.sub_up_voter_compensation', nickname: comment_or_post_user.nickname, type: type)
      end
      u.decrement! :up_votes_count
    end

    down_voters.each do |u|
      if u != comment_or_post_user
        u.increment! :points_count, POINTS_CONFIG['down_voter_compensation']
        u.receive_message POINTS_CONFIG['down_voter_compensation'], u.points_count, I18n.t('controller.comment.message.sub_down_voter_compensation', nickname: comment_or_post_user.nickname, type: type)
      end
      u.decrement! :down_votes_count
    end

    if user != comment_or_post_user
      user.increment! :points_count, POINTS_CONFIG['commenter_compensation']
      user.receive_message POINTS_CONFIG['commenter_compensation'], user.points_count, I18n.t('controller.comment.message.sub_commenter_compensation', nickname: comment_or_post_user.nickname, type: type)
      user.decrement! :comments_count
    end
  end

  def cleared_by(deleter)
    up_voters.each do |u|
      u.increment! :points_count, POINTS_CONFIG['up_voter_compensation']
      u.receive_message POINTS_CONFIG['up_voter_compensation'], u.points_count, I18n.t('controller.comment.message.up_voter_compensation', nickname: user.nickname)
      u.decrement! :up_votes_count
    end

    down_voters.each do |u|
      u.increment! :points_count, POINTS_CONFIG['down_voter_compensation']
      u.receive_message POINTS_CONFIG['down_voter_compensation'], u.points_count, I18n.t('controller.comment.message.down_voter_compensation', nickname: user.nickname)
      u.decrement! :down_votes_count
    end

    if user == deleter
      user.increment! :points_count, POINTS_CONFIG['delete_comment']
      user.receive_message POINTS_CONFIG['delete_comment'], user.points_count, I18n.t('controller.comment.message.delete_by_self')
    else
      user.receive_message 0, user.points_count, I18n.t('controller.comment.message.delete_by_admin', admin: deleter.nickname)
    end

    user.decrement! :comments_count
  end

  private

  def generate_floor
    comment_or_post = commentable

    self.floor = if comment_or_post.instance_of? Comment
      comment_or_post.floor + '.' + (comment_or_post.comments.count + 1).to_s
    else
      (comment_or_post.direct_comments_count + 1).to_s
    end
  end
end
