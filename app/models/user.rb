class User < ActiveRecord::Base
  attr_accessible :nickname, :email, :password, :password_confirmation, :avatar, :words, :invitation_token

  has_many :sent_secrets, foreign_key: :sender_id, class_name: :Secret, dependent: true
  has_many :received_secrets, foreign_key: :receiver_id, class_name: :Secret, dependent: true

  def has_followed?(other_user)
    following_relationships.find_by_followed_id other_user.id
  end

  def follow(other_user)
    following_relationships.build followed_id: other_user.id
  end

  def follow!(other_user)
    following_relationships.create! followed_id: other_user.id
    increment! :followings_count
    other_user.increment! :followeds_count
  end

  def unfollow!(other_user)
    following_relationships.find_by_followed_id(other_user.id).destroy
    decrement! :followings_count
    other_user.decrement! :followeds_count
  end

  def has_collected?(post)
    collecting_relationships.find_by_post_id post.id
  end

  def collect!(post)
    # TODO
  end

  def uncollect!(post)
    # TODO
  end

  def has_voted?(votable)
    voted_up = voting_up_relationships.find_by_votable_id_and_votable_type(votable.id, votable.class)
    voted_down = voting_down_relationships.find_by_votable_id_and_votable_type(votable.id, votable.class)
    voted_up or voted_down
  end

  def vote_up!(votable)
    # TODO
  end

  def vote_down!(votable)
    # TODO
  end

  def has_secret?(secret)
    id.in? [secret.sender_id, secret.receiver_id]
  end
end
