# coding: utf-8

class NodeGroup < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :name, :position

  has_many :nodes

  before_create { generate_token :permalink }

  default_scope order: 'node_groups.position ASC'

  def to_param
    permalink
  end

  def self.find(id)
    find_by_permalink(id)
  end

  def self.technicals
    @technicals ||= where name: ['前端开发', '后端开发', '功能开发', '上线运行']
  end
end
