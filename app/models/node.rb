# coding: utf-8

class Node < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :name, :position_text, :node_group_id

  has_many :posts
  belongs_to :node_group

  validates :name, presence: true, length: { maximum: EXTRA_CONFIG['node_name_max'] }
  validates :position, presence: true, if: :persisted?
  validates :node_group_id, presence: true, inclusion: { in: ->(record) { NodeGroup.pluck(:id) } }

  before_create { generate_token :permalink }

  default_scope order: 'nodes.position ASC'

  def to_param
    permalink
  end

  def self.children
    @children ||= where name: EXTRA_CONFIG['children']
  end

  def position_text
    position.to_s
  end

  def position_text=(input_text)
    self.position = input_text.to_i if input_text
  end
end
