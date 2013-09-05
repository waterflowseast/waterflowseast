class Post < ActiveRecord::Base
  attr_accessible :title, :content, :extra_info, :node_id

  default_scope order: 'posts.updated_at DESC'

  def points_cost
    return 0 if node.node_group.in? NodeGroup.technicals
    return 0 if node.in? Node.children
    POINTS_CONFIG['non_technical_post'].abs
  end
end
