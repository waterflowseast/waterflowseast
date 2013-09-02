class Invitation < ActiveRecord::Base
  attr_accessible :receiver_email

  default_scope order: 'invitations.created_at DESC'
end
