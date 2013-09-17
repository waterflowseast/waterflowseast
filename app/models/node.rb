# coding: utf-8

class Node < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :name, :position, :node_group_id

  has_many :posts
  belongs_to :node_group
  
  before_create { generate_token :permalink }

  default_scope order: 'nodes.position ASC'

  def to_param
    permalink
  end

  def self.find(id)
    find_by_permalink(id)
  end

  def self.children
    @children ||= where name: ['儿歌', '寓言', '儿童文学']
  end
end
