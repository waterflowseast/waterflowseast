class Invitation < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :receiver_email

  belongs_to :sender, class_name: :User
  has_one :receiver, class_name: :User

  validates :sender_id, presence: true
  validates :receiver_email, presence: true, format: { with: Waterflowseast::Regex.email }, uniqueness: { case_sensitive: false }

  before_create { generate_token :token }

  default_scope order: 'invitations.created_at DESC'

  def receiver_email=(email)
    write_attribute(:receiver_email, email.downcase)
  end
end
