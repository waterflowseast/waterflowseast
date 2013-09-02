class Comment < ActiveRecord::Base
  attr_accessible :commentable_id, :commentable_type, :content

  default_scope order: 'comments.created_at ASC'
end
