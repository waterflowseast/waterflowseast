# coding: utf-8

class NodeGroup < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :name, :position_text

  has_many :nodes

  validates :name, presence: true, length: { maximum: EXTRA_CONFIG['node_group_name_max'] }
  validates :position, presence: true, if: :persisted?

  before_create { generate_token :permalink }

  default_scope order: 'node_groups.position ASC'

  def to_param
    permalink
  end

  def self.technicals
    @technicals ||= where name: EXTRA_CONFIG['technicals']
  end

  def position_text
    position.to_s
  end

  def position_text=(input_text)
    self.position = input_text.to_i if input_text
  end
end
