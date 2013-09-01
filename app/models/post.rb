class Post < ActiveRecord::Base
  attr_accessible :title, :content, :extra_info, :node_id
end
