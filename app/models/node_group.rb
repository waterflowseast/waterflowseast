class NodeGroup < ActiveRecord::Base
  attr_accessible :name, :position

  default_scope order: 'node_groups.position ASC'
end
