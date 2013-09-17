class User < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  attr_accessible :nickname, :email, :password, :password_confirmation, :avatar, :words, :invitation_token

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  has_many :following_relationships, foreign_key: :follower_id, dependent: :destroy
  has_many :followings, through: :following_relationships, source: :followed
  has_many :reverse_following_relationships, foreign_key: :followed_id, class_name: :FollowingRelationship, dependent: :destroy
  has_many :followeds, through: :reverse_following_relationships, source: :follower

  has_many :collecting_relationships, dependent: :destroy
  has_many :collections, through: :collecting_relationships, source: :post

  has_many :voting_up_relationships, dependent: :destroy
  has_many :post_up_votes, through: :voting_up_relationships, source: :votable, source_type: :Post
  has_many :comment_up_votes, through: :voting_up_relationships, source: :votable, source_type: :Comment

  has_many :voting_down_relationships, dependent: :destroy
  has_many :post_down_votes, through: :voting_down_relationships, source: :votable, source_type: :Post
  has_many :comment_down_votes, through: :voting_down_relationships, source: :votable, source_type: :Comment

  has_many :sent_secrets, foreign_key: :sender_id, class_name: :Secret, dependent: :destroy
  has_many :received_secrets, foreign_key: :receiver_id, class_name: :Secret, dependent: :destroy

  has_many :messages, dependent: :destroy

  has_many :invitations, foreign_key: :sender_id, dependent: :destroy
  belongs_to :invitation

  def up_votes
    post_up_votes + comment_up_votes
  end

  def down_votes
    post_down_votes + comment_down_votes
  end

  def has_followed?(other_user)
    following_relationships.find_by_followed_id other_user.id
  end

  def follow!(other_user)
    following_relationships.create! followed_id: other_user.id

    # you follow people, your points will be subtracted and system will send you a message
    increment! :points_count, POINTS_CONFIG['follow']
    receive_message POINTS_CONFIG['follow'], points_count, I18n.t('controller.following_relationship.message.points_subtraction', nickname: other_user.nickname)

    # the one you just followed, his points will be added and system will send him a message
    other_user.increment! :points_count, POINTS_CONFIG['be_followed']
    other_user.receive_message POINTS_CONFIG['be_followed'], other_user.points_count, I18n.t('controller.following_relationship.message.points_addition', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.following_relationship.message.to_followeds', name_a: nickname, name_b: other_user.nickname)
    end

    # update corresponding count
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
    collecting_relationships.create! post_id: post.id
    post_user = post.user

    # you collect others' posts, your points will be subtracted and system will send you a message
    increment! :points_count, POINTS_CONFIG['collect']
    receive_message POINTS_CONFIG['collect'], points_count, I18n.t('controller.collecting_relationship.message.points_subtraction', nickname: post_user.nickname)

    # the one whose post you just collected, his points will be added and system will send him a message
    post_user.increment! :points_count, POINTS_CONFIG['be_collected']
    post_user.receive_message POINTS_CONFIG['be_collected'], post_user.points_count, I18n.t('controller.collecting_relationship.message.points_addition', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.collecting_relationship.message.to_followeds', name_a: nickname, name_b: post_user.nickname)
    end

    # update corresponding count
    increment! :collections_count
    post.increment! :collectors_count

    # if this post's collectors amount reaches the limit, system will consider it great post and make it not deletable
    if (post.collectors_count == POINTS_CONFIG['valuable_limit_for_collecting']) and post.can_be_deleted?
      post.toggle! :can_be_deleted
      post_user.increment! :great_posts_count
    end

    # if this post's collectors amount hits the bonus limit at its first time, the author of the post and the inviter of the author will get the bonus points and a message from the system
    bonus_points = post.points_bonus_for_collecting
    if bonus_points > post.highest_bonus_points
      post.update_attribute :highest_bonus_points, bonus_points
      post_user.increment! :points_count, bonus_points
      post_user.receive_message bonus_points, post_user.points_count, I18n.t('controller.collecting_relationship.message.bonus', count: post.collectors_count, bonus: bonus_points)

      inviter = post_user.inviter
      if inviter
        inviter.increment! :points_count, bonus_points
        inviter.receive_message bonus_points, inviter.points_count, I18n.t('controller.collecting_relationship.message.inviter_bonus', name: post_user.nickname, count: post.collectors_count, bonus: bonus_points)
      end
    end
  end

  def uncollect!(post)
    collecting_relationships.find_by_post_id(post.id).destroy
    decrement! :collections_count
    post.decrement! :collectors_count
  end

  def has_voted?(votable)
    voted_up = voting_up_relationships.find_by_votable_id_and_votable_type(votable.id, votable.class)
    voted_down = voting_down_relationships.find_by_votable_id_and_votable_type(votable.id, votable.class)
    voted_up or voted_down
  end

  def vote_up!(votable)
    voting_up_relationships.create! votable: votable
    votable_user = votable.user

    # you vote up others' posts or comments, your points will be subtracted and system will send you a message
    increment! :points_count, POINTS_CONFIG['vote_up']
    receive_message POINTS_CONFIG['vote_up'], points_count, I18n.t('controller.voting_up_relationship.message.points_subtraction', nickname: votable_user.nickname)

    # the one whose post or comment you just voted up, his points will be added and system will send him a message
    votable_user.increment! :points_count, POINTS_CONFIG['be_voted_up']
    votable_user.receive_message POINTS_CONFIG['be_voted_up'], votable_user.points_count, I18n.t('controller.voting_up_relationship.message.points_addition', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.voting_up_relationship.message.to_followeds', name_a: nickname, name_b: votable_user.nickname)
    end

    # update corresponding count
    increment! :up_votes_count
    votable.increment! :up_voters_count

    # if the votable is a post, and its up-voters ammount reaches the limit, system will consider it great post and make it not deletable
    if (votable.instance_of? Post) and (votable.up_voters_count == POINTS_CONFIG['valuable_limit_for_voting_up']) and votable.can_be_deleted?
      votable.toggle! :can_be_deleted
      votable_user.increment! :great_posts_count
    end

    # if this votable's up-voters ammount hits the bonus limit, the author of the votable and the inviter of the author will get the bonus points and a message from the system
    bonus_points = votable.points_bonus_for_voting_up
    if bonus_points > 0
      votable_user.increment! :points_count, bonus_points
      votable_user.receive_message bonus_points, votable_user.points_count, I18n.t('controller.voting_up_relationship.message.bonus', count: votable.up_voters_count, bonus: bonus_points)

      inviter = votable_user.inviter
      if inviter
        inviter.increment! :points_count, bonus_points
        inviter.receive_message bonus_points, inviter.points_count, I18n.t('controller.voting_up_relationship.message.inviter_bonus', name: votable_user.nickname, count: votable.up_voters_count, bonus: bonus_points)
      end
    end
  end

  def vote_down!(votable)
    voting_down_relationships.create! votable: votable
    votable_user = votable.user

    # you vote down others' posts or comments, your points will be subtracted and system will send you a message
    increment! :points_count, POINTS_CONFIG['vote_down']
    receive_message POINTS_CONFIG['vote_down'], points_count, I18n.t('controller.voting_down_relationship.message.points_subtraction', nickname: votable_user.nickname)

    # the one whose post or comment you just voted down, system will send him a message
    votable_user.receive_message 0, votable_user.points_count, I18n.t('controller.voting_down_relationship.message.warning', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.voting_down_relationship.message.to_followeds', name_a: nickname, name_b: votable_user.nickname)
    end

    # update corresponding count
    increment! :down_votes_count
    votable.increment! :down_voters_count
  end

  def has_secret?(secret)
    id.in? [secret.sender_id, secret.receiver_id]
  end

  def secret_has_been_sent_to(receiver)
    if receiver.has_followed? self
      changed_points_for_sender = 0
      changed_points_for_receiver = 0
    else
      changed_points_for_sender = POINTS_CONFIG['send_secret']
      changed_points_for_receiver = POINTS_CONFIG['received_secret']

      # the receiver didn't follow you, you send him a secret, your points will be subtracted and his points will be added
      increment! :points_count, changed_points_for_sender
      receiver.increment! :points_count, changed_points_for_receiver
    end

    # system will send message to you and the receiver
    receive_message changed_points_for_sender, points_count, I18n.t('controller.secret.message.points_subtraction', nickname: receiver.nickname)
    receiver.receive_message changed_points_for_receiver, receiver.points_count, I18n.t('controller.secret.message.points_addition', nickname: nickname)

    # update corresponding count
    increment! :sent_secrets_count
    receiver.increment! :received_secrets_count
  end

  def destroy_sent_secret(secret)
    decrement! :sent_secrets_count

    if secret.receiver_deleted?
      secret.destroy
    else
      secret.toggle! :sender_deleted
    end
  end

  def destroy_received_secret(secret)
    decrement! :received_secrets_count

    if secret.sender_deleted?
      secret.destroy
    else
      secret.toggle! :receiver_deleted
    end
  end

  def receive_message(changed_points, current_points, content)
    message = messages.build
    message.changed_points = changed_points
    message.current_points = current_points
    message.content = content
    message.save

    increment! :messages_count
  end

  def destroy_messages(deleted_ids)
    if (deleted_size = deleted_ids.size) > 0
      Message.delete deleted_ids
      decrement! :messages_count, deleted_size
    end
  end

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end

  def send_invitation(sent_invitation)
    # TODO: Notifier.send_invitation(sent_invitation).deliver

    # you invite people, your points will be subtracted and system will send you a message
    increment! :points_count, POINTS_CONFIG['invite']
    receive_message POINTS_CONFIG['invite'], points_count, I18n.t('controller.invitation.message.points_subtraction', email: sent_invitation.receiver_email)

    increment! :sent_invitations_count
  end

  def has_created_post(post)
    changed_points = post.points_changed
    node = post.node

    # you create a post, if the post will cost points or gain points, then your points will be changed and system will send you a message
    if changed_points != 0
      increment! :points_count, changed_points
      receive_message changed_points, points_count, I18n.t("controller.post.message.points_changed", node_group: node.node_group, node: node)
    end

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.post.message.to_followeds', nickname: nickname, node_group: node.node_group, node: node)
    end
    
    # update corresponding count
    increment! :posts_count
  end

  def destroy_post(post)
    post.total_comments.each {|c| c.compensate_from(post) }
    post.cleared_by self
    post.destroy
  end

  def has_created_comment(comment)
    comment_or_post = comment.commentable
    is_comment = comment_or_post.instance_of? Comment
    type = is_comment ? I18n.t('controller.comment.is_comment') : I18n.t('controller.comment.is_post')

    # you create a comment, your points will be subtracted and system will send you a message
    increment! :points_count, POINTS_CONFIG['comment']
    receive_message POINTS_CONFIG['comment'], points_count, I18n.t('controller.comment.message.points_subtraction', nickname: comment_or_post.user.nickname, type: type)

    # update corresponding count
    increment! :comments_count

    # ancestors of the comment will increase their total_comments_count, and if the commentable of the comment is a post, the post's direct_comments_count will be increased
    comment.ancestors.each {|c| c.increment! :total_comments_count }
    comment_or_post.increment! :direct_comments_count unless is_comment
  end

  def destroy_comment(comment)
    comment.total_comments.each {|c| c.compensate_from(comment) }
    comment.cleared_by self
    comment.destroy
  end

  def destroy_self
    # TODO
  end
end
