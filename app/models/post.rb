class Post < ActiveRecord::Base
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include Waterflowseast::TokenGenerator
  include Waterflowseast::IncreaseDecrease

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
  validates :node_id, presence: true, inclusion: { in: ->(record) { Node.pluck(:id) } }

  before_create { generate_token :permalink }
  before_create { self.last_commented_at = Time.zone.now }

  default_scope order: 'posts.last_commented_at DESC'

  def to_param
    permalink
  end

  def extra_info=(text)
    write_attribute :extra_info, (text.present? ? text : nil)
  end

  tire.mapping do
    indexes :title, analyzer: 'smartcn', boost: 10
    indexes :content, analyzer: 'smartcn'
    indexes :extra_info, analyzer: 'smartcn'
    indexes :collectors_count, type: 'integer', index: :not_analyzed
    indexes :up_voters_count, type: 'integer', index: :not_analyzed
    indexes :total_comments_count, type: 'integer', index: :not_analyzed
    indexes :views_count, type: 'integer', index: :not_analyzed
    indexes :last_commented_at, type: 'date'
    indexes :node_permalink, index: :not_analyzed
    indexes :node_group_permalink, index: :not_analyzed
  end

  def node_permalink
    node.permalink
  end

  def node_group_permalink
    node.node_group.permalink
  end

  def to_indexed_json
    to_json(only: [:title, :content, :extra_info, :collectors_count, :up_voters_count, :total_comments_count, :views_count, :last_commented_at],
            methods: [:node_permalink, :node_group_permalink])
  end

  def self.search(params)
    tire.search(load: true, page: params[:page], per_page: EXTRA_CONFIG['per_page']) do
      query { string params[:query], default_operator: "AND" } if params[:query].present?

      sorted_columns = []

      case params[:hot]
      when 'collectors'
        filter :numeric_range, collectors_count: { gt: EXTRA_CONFIG['collectors_limit'] }
        sorted_columns << :collectors_count
      when 'up_voters'
        filter :numeric_range, up_voters_count: { gt: EXTRA_CONFIG['up_voters_limit'] }
        sorted_columns << :up_voters_count
      when 'comments'
        filter :numeric_range, total_comments_count: { gt: EXTRA_CONFIG['total_comments_limit'] }
        sorted_columns << :total_comments_count
      when 'views'
        filter :numeric_range, views_count: { gt: EXTRA_CONFIG['views_limit'] }
        sorted_columns << :views_count
      end

      case params[:time]
      when 'today'
        filter :range, last_commented_at: { gt: Time.zone.now.beginning_of_day }
        sorted_columns << :last_commented_at
      when 'three_days'
        filter :range, last_commented_at: { gt: 2.days.ago.beginning_of_day }
        sorted_columns << :last_commented_at
      when 'a_week'
        filter :range, last_commented_at: { gt: 6.days.ago.beginning_of_day }
        sorted_columns << :last_commented_at
      when 'a_month'
        filter :range, last_commented_at: { gt: 1.month.ago.beginning_of_day }
        sorted_columns << :last_commented_at
      end

      if params[:node].present?
        filter :term, node_permalink: params[:node]
      elsif params[:node_group].present?
        filter :term, node_group_permalink: params[:node_group]
      end

      sorted_columns << :last_commented_at unless :last_commented_at.in? sorted_columns

      sort do
        sorted_columns.each do |sorted_column|
          by sorted_column, :desc
        end
      end
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
      u.increase_reload! :points_count, POINTS_CONFIG['up_voter_compensation']
      u.receive_message POINTS_CONFIG['up_voter_compensation'], u.points_count, I18n.t('controller.post.message.up_voter_compensation', nickname: user.nickname)
      u.decrease! :up_votes_count
    end

    down_voters.each do |u|
      u.increase_reload! :points_count, POINTS_CONFIG['down_voter_compensation']
      u.receive_message POINTS_CONFIG['down_voter_compensation'], u.points_count, I18n.t('controller.post.message.down_voter_compensation', nickname: user.nickname)
      u.decrease! :down_votes_count
    end

    collectors.each do |u|
      u.increase_reload! :points_count, POINTS_CONFIG['collector_compensation']
      u.receive_message POINTS_CONFIG['collector_compensation'], u.points_count, I18n.t('controller.post.message.collector_compensation', nickname: user.nickname)
      u.decrease! :collections_count
    end

    if user == deleter
      user.increase_reload! :points_count, POINTS_CONFIG['delete_post']
      user.receive_message POINTS_CONFIG['delete_post'], user.points_count, I18n.t('controller.post.message.delete_by_self', title: title)
    else
      user.receive_message 0, user.points_count, I18n.t('controller.post.message.delete_by_admin', admin: deleter.nickname, title: title)
    end
    user.decrease! :posts_count
  end
end
