# coding: utf-8

class NodeGroup < ActiveRecord::Base
  attr_accessible :name, :position

  default_scope order: 'node_groups.position ASC'

  def self.technicals
    @technicals ||= where name: ['前端开发', '后端开发', '功能开发', '上线运行']
  end
end
