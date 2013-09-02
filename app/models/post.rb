class Post < ActiveRecord::Base
  attr_accessible :title, :content, :extra_info, :node_id

  default_scope order: 'posts.updated_at DESC'
end
