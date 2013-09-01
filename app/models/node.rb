class Node < ActiveRecord::Base
  attr_accessible :name, :position, :node_group_id
end
