# coding: utf-8

class Node < ActiveRecord::Base
  attr_accessible :name, :position, :node_group_id

  default_scope order: 'nodes.position ASC'

  def self.children
    @children ||= where name: ['儿歌', '寓言', '儿童文学']
  end
end
