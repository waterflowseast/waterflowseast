class User < ActiveRecord::Base
  include Waterflowseast::TokenGenerator
  include Waterflowseast::IncreaseDecrease
  attr_accessible :nickname, :email, :password, :password_confirmation, :avatar, :remove_avatar, :words, :invitation_token
  has_secure_password

  mount_uploader :avatar, AvatarUploader

  has_many :posts
  has_many :comments

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

  validates :nickname, format: { with: Waterflowseast::Regex.nickname }, uniqueness: { case_sensitive: false }
  validates :email, format: { with: Waterflowseast::Regex.email }, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: EXTRA_CONFIG['password_min'], maximum: EXTRA_CONFIG['password_max'] }, if: :password_changed?
  validates :password_confirmation, presence: true, if: :password_changed?
  validates :words, length: { maximum: EXTRA_CONFIG['words_max'] }, if: ->(user) { ! user.words.nil? }
  validates :invitation_id, presence: true, if: ->(user) { user.new_record? and ( (User.pluck(:id).max || 0) >= EXTRA_CONFIG['sign_in_limit_without_invitation'] ) }
  validate :invitation_check, if: ->(user) { user.new_record? and ! user.invitation.nil? }

  before_create { generate_token :permalink }
  after_save :reset_password_changed, if: :password_changed?

  scope :available_users, -> { where("users.signed_up_confirmed_at IS NOT NULL") }

  def to_param
    permalink
  end

  # have to redefine this method because Carrierwave uses to_param value as the id, and find method as the way to find object
  def self.find(id)
    find_by_permalink id
  end

  # have to redifine this method because find method has been redefined to use find_by_permalink
  def reload(options = nil)
    clear_aggregation_cache
    clear_association_cache

    fresh_object = 
      if options && options[:lock]
        self.class.unscoped { self.class.lock.find_by_id(id) }
      else
        self.class.unscoped { self.class.find_by_id(id) }
      end

    @attributes.update(fresh_object.instance_variable_get('@attributes'))
    @columns_hash = fresh_object.instance_variable_get('@columns_hash')

    @attributes_cache = {}
    self
  end

  def to_key
    [permalink]
  end

  def words=(text)
    write_attribute :words, (text.present? ? text : nil)
  end

  def self.search(names)
    wildcard_names = names.split.map {|name| "%#{name}%" }
    where arel_table[:nickname].matches_any(wildcard_names)
  end

  def self.select_sort(sort)
    case sort
    when 'sign_up_early'
      order('users.signed_up_confirmed_at ASC')
    when 'sign_in_lately'
      order('users.last_signed_in_at DESC')
    when 'followeds_most'
      order('users.followeds_count DESC')
    when 'great_posts_most'
      order('users.great_posts_count DESC')
    when 'posts_most'
      order('users.posts_count DESC')
    when 'points_most'
      order('users.points_count DESC')
    else
      scoped
    end
  end

  def invitation_check
    receiver_email = invitation.receiver_email

    errors.add :invitation_id, :not_same, receiver_email: receiver_email if receiver_email != email
    errors.add :invitation_id, :signed_up, receiver_email: receiver_email if User.find_by_email receiver_email
  end

  def email=(unprocessed_email)
    write_attribute :email, unprocessed_email.downcase
  end

  def password=(unencrypted_password)
    super
    @password_changed = true

    unless unencrypted_password.blank?
      generate_token :remember_token
    end
  end

  def password_changed?
    @password_changed ||= false
  end

  def reset_password_changed
    @password_changed = false
  end

  def inviter
    invitation.sender if invitation
  end

  # This is basically useless, because the result is an Array of different instances (of Post and Comment), not ActiveRecord::Relation,
  # so you can't do paginate. Only used when all you need is just up_votes and no extra filtering conditions are required.
  def up_votes
    post_up_votes + comment_up_votes
  end

  def down_votes
    post_down_votes + comment_down_votes
  end

  def available_sent_secrets
    sent_secrets.where(sender_deleted: false)
  end

  def available_received_secrets
    received_secrets.where(receiver_deleted: false)
  end

  def has_followed?(other_user)
    following_relationships.find_by_followed_id other_user.id
  end

  def follow!(other_user)
    following_relationships.create! followed_id: other_user.id

    # you follow people, your points will be subtracted and system will send you a message
    increase_reload! :points_count, POINTS_CONFIG['follow']
    receive_message POINTS_CONFIG['follow'], points_count, I18n.t('controller.following_relationship.message.points_subtraction', nickname: other_user.nickname)

    # the one you just followed, his points will be added and system will send him a message
    other_user.increase_reload! :points_count, POINTS_CONFIG['be_followed']
    other_user.receive_message POINTS_CONFIG['be_followed'], other_user.points_count, I18n.t('controller.following_relationship.message.points_addition', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.following_relationship.message.to_followeds', name_a: nickname, name_b: other_user.nickname)
    end

    # update corresponding count
    increase! :followings_count
    other_user.increase! :followeds_count
  end

  def unfollow!(other_user)
    following_relationships.find_by_followed_id(other_user.id).destroy
    decrease! :followings_count
    other_user.decrease! :followeds_count
  end

  def has_collected?(post)
    collecting_relationships.find_by_post_id post.id
  end

  def collect!(post)
    collecting_relationships.create! post_id: post.id
    post_user = post.user

    # you collect others' posts, your points will be subtracted and system will send you a message
    increase_reload! :points_count, POINTS_CONFIG['collect']
    receive_message POINTS_CONFIG['collect'], points_count, I18n.t('controller.collecting_relationship.message.points_subtraction', nickname: post_user.nickname)

    # the one whose post you just collected, his points will be added and system will send him a message
    post_user.increase_reload! :points_count, POINTS_CONFIG['be_collected']
    post_user.receive_message POINTS_CONFIG['be_collected'], post_user.points_count, I18n.t('controller.collecting_relationship.message.points_addition', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.collecting_relationship.message.to_followeds', name_a: nickname, name_b: post_user.nickname)
    end

    # update corresponding count
    increase! :collections_count
    post.increase_reload! :collectors_count
    post.tire.update_index

    # if this post's collectors amount reaches the limit, system will consider it great post and make it not deletable
    if (post.collectors_count == POINTS_CONFIG['valuable_limit_for_collecting']) and post.can_be_deleted?
      post.toggle! :can_be_deleted
      post_user.increase! :great_posts_count
    end

    # if this post's collectors amount hits the bonus limit at its first time, the author of the post and the inviter of the author will get the bonus points and a message from the system
    bonus_points = post.points_bonus_for_collecting
    if bonus_points > post.highest_bonus_points
      post.update_attribute :highest_bonus_points, bonus_points
      post_user.increase_reload! :points_count, bonus_points
      post_user.receive_message bonus_points, post_user.points_count, I18n.t('controller.collecting_relationship.message.bonus', count: post.collectors_count, bonus: bonus_points)

      user_inviter = post_user.inviter
      if user_inviter
        user_inviter.increase_reload! :points_count, bonus_points
        user_inviter.receive_message bonus_points, user_inviter.points_count, I18n.t('controller.collecting_relationship.message.inviter_bonus', name: post_user.nickname, count: post.collectors_count, bonus: bonus_points)
      end
    end
  end

  def uncollect!(post)
    collecting_relationships.find_by_post_id(post.id).destroy
    decrease! :collections_count
    post.decrease_reload! :collectors_count
    post.tire.update_index
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
    increase_reload! :points_count, POINTS_CONFIG['vote_up']
    receive_message POINTS_CONFIG['vote_up'], points_count, I18n.t('controller.voting_up_relationship.message.points_subtraction', nickname: votable_user.nickname)

    # the one whose post or comment you just voted up, his points will be added and system will send him a message
    votable_user.increase_reload! :points_count, POINTS_CONFIG['be_voted_up']
    votable_user.receive_message POINTS_CONFIG['be_voted_up'], votable_user.points_count, I18n.t('controller.voting_up_relationship.message.points_addition', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.voting_up_relationship.message.to_followeds', name_a: nickname, name_b: votable_user.nickname)
    end

    # update corresponding count
    increase! :up_votes_count
    votable.increase_reload! :up_voters_count
    votable.tire.update_index if votable.instance_of? Post

    # if the votable is a post, and its up-voters ammount reaches the limit, system will consider it great post and make it not deletable
    if (votable.instance_of? Post) and (votable.up_voters_count == POINTS_CONFIG['valuable_limit_for_voting_up']) and votable.can_be_deleted?
      votable.toggle! :can_be_deleted
      votable_user.increase! :great_posts_count
    end

    # if this votable's up-voters ammount hits the bonus limit, the author of the votable and the inviter of the author will get the bonus points and a message from the system
    bonus_points = votable.points_bonus_for_voting_up
    if bonus_points > 0
      votable_user.increase_reload! :points_count, bonus_points
      votable_user.receive_message bonus_points, votable_user.points_count, I18n.t('controller.voting_up_relationship.message.bonus', count: votable.up_voters_count, bonus: bonus_points)

      user_inviter = votable_user.inviter
      if user_inviter
        user_inviter.increase_reload! :points_count, bonus_points
        user_inviter.receive_message bonus_points, user_inviter.points_count, I18n.t('controller.voting_up_relationship.message.inviter_bonus', name: votable_user.nickname, count: votable.up_voters_count, bonus: bonus_points)
      end
    end
  end

  def vote_down!(votable)
    voting_down_relationships.create! votable: votable
    votable_user = votable.user

    # you vote down others' posts or comments, your points will be subtracted and system will send you a message
    increase_reload! :points_count, POINTS_CONFIG['vote_down']
    receive_message POINTS_CONFIG['vote_down'], points_count, I18n.t('controller.voting_down_relationship.message.points_subtraction', nickname: votable_user.nickname)

    # the one whose post or comment you just voted down, system will send him a message
    votable_user.receive_message 0, votable_user.points_count, I18n.t('controller.voting_down_relationship.message.warning', nickname: nickname)

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.voting_down_relationship.message.to_followeds', name_a: nickname, name_b: votable_user.nickname)
    end

    # update corresponding count
    increase! :down_votes_count
    votable.increase! :down_voters_count
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
      increase_reload! :points_count, changed_points_for_sender
      receiver.increase_reload! :points_count, changed_points_for_receiver
    end

    # system will send message to you and the receiver
    receive_message changed_points_for_sender, points_count, I18n.t('controller.secret.message.points_subtraction', nickname: receiver.nickname)
    receiver.receive_message changed_points_for_receiver, receiver.points_count, I18n.t('controller.secret.message.points_addition', nickname: nickname)

    # update corresponding count
    increase! :sent_secrets_count
    receiver.increase! :received_secrets_count
  end

  def destroy_sent_secret(secret)
    decrease! :sent_secrets_count

    if secret.receiver_deleted?
      secret.destroy
    else
      secret.toggle! :sender_deleted
    end
  end

  def destroy_received_secret(secret)
    decrease! :received_secrets_count

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

    increase! :messages_count
  end

  def destroy_messages(deleted_ids)
    if (deleted_size = deleted_ids.size) > 0
      Message.delete deleted_ids
      decrease! :messages_count, deleted_size
    end
  end

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end

  def send_invitation(sent_invitation)
    Notifier.send_invitation(sent_invitation).deliver

    # you invite people, your points will be subtracted and system will send you a message
    increase_reload! :points_count, POINTS_CONFIG['invite']
    receive_message POINTS_CONFIG['invite'], points_count, I18n.t('controller.invitation.message.points_subtraction', email: sent_invitation.receiver_email)

    increase! :sent_invitations_count
  end

  def has_created_post(post)
    changed_points = post.points_changed
    node = post.node

    # you create a post, if the post will cost points or gain points, then your points will be changed and system will send you a message
    if changed_points != 0
      increase_reload! :points_count, changed_points
      receive_message changed_points, points_count, I18n.t("controller.post.message.points_subtraction", node_group: node.node_group.name, node: node.name)
    end

    # those people who followed you will receive a message from the system
    followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.post.message.to_followeds', nickname: nickname, node_group: node.node_group.name, node: node.name)
    end
    
    # update corresponding count
    increase! :posts_count
  end

  def destroy_post(post)
    post.sub_comments.each {|c| c.compensate_from(post) }
    post.cleared_by self
    post.destroy
  end

  def has_created_comment(comment)
    comment_or_post = comment.commentable
    is_comment = comment_or_post.instance_of? Comment
    type = is_comment ? I18n.t('controller.comment.is_comment') : I18n.t('controller.comment.is_post')

    # you create a comment, your points will be subtracted and system will send you a message
    increase_reload! :points_count, POINTS_CONFIG['comment']
    receive_message POINTS_CONFIG['comment'], points_count, I18n.t('controller.comment.message.points_subtraction', nickname: comment_or_post.user.nickname, type: type)

    # update corresponding count
    increase! :comments_count
    
    comment_ancestors = comment.ancestors
    original_post = comment_ancestors.last

    # ancestors of the comment will increase their total_comments_count, and if the commentable of the comment is a post, the post's direct_comments_count will be increased
    comment_ancestors.each {|c| c.increase! :total_comments_count }
    comment_or_post.increase! :direct_comments_count unless is_comment
    original_post.reload.tire.update_index
  end

  def destroy_comment(comment)
    comment_or_post = comment.commentable
    is_comment = comment_or_post.instance_of? Comment

    deleted_sub_comments = comment.sub_comments
    deleted_comments_count = deleted_sub_comments.count + 1

    comment_ancestors = comment.ancestors
    original_post = comment_ancestors.last

    comment_ancestors.each {|c| c.decrease! :total_comments_count, deleted_comments_count }
    comment_or_post.decrease! :direct_comments_count unless is_comment
    original_post.reload.tire.update_index

    deleted_sub_comments.each {|c| c.compensate_from(comment) }
    comment.cleared_by self
    comment.destroy
  end

  def destroy_self
    followings.each {|u| u.decrease! :followeds_count }
    followeds.each {|u| u.decrease! :followings_count }

    collections.each do |p|
      p.decrease_reload! :collectors_count
      p.tire.update_index
    end

    up_votes.each do |v|
      if v.instance_of? Post
        v.decrease_reload! :up_voters_count
        v.tire.update_index
      else
        v.decrease! :up_voters_count
      end
    end

    down_votes.each {|v| v.decrease! :down_voters_count }
    sent_secrets.includes(:receiver).where(receiver_deleted: false).map(&:receiver).each {|u| u.decrease! :received_secrets_count }
    received_secrets.includes(:sender).where(sender_deleted: false).map(&:sender).each {|u| u.decrease! :sent_secrets_count }
    User.where(email: invitations.pluck(:receiver_email)).where('users.invitation_id IS NOT NULL').update_all invitation_id: nil
    comments.each {|c| destroy_comment(c) }
    posts.each {|p| destroy_post(p) }

    destroy
  end

  def send_email_confirm
    generate_token :confirm_token and save!
    Notifier.send_email_confirm(self).deliver
  end

  def confirmed?
    ! signed_up_confirmed_at.nil?
  end

  def out_of_confirm?
    created_at < EXTRA_CONFIG['confirm_out_of_time_in_hours'].hours.ago
  end

  def confirm_email
    self.signed_up_confirmed_at = Time.zone.now
    self.last_signed_in_at = Time.zone.now
    save!

    # you confirmed your account, your points will be added and system will send you a message
    increase_reload! :points_count, POINTS_CONFIG['new_account']
    receive_message POINTS_CONFIG['new_account'], points_count, I18n.t('controller.email_confirm.message.points_addition', email: email)
  end

  def send_password_reset
    generate_token :reset_token
    self.reset_deadline = EXTRA_CONFIG['reset_out_of_time_in_minutes'].minutes.from_now
    save!

    Notifier.send_password_reset(self).deliver
  end

  def out_of_reset?
    reset_deadline < Time.zone.now
  end

  def reset_password
    self.reset_token = nil
    self.reset_deadline = nil
    save!
  end

  def can_get_signin_points?
    last_signed_in_at.beginning_of_day < Time.zone.now.beginning_of_day
  end

  def signin
    if can_get_signin_points?
      increase_reload! :points_count, POINTS_CONFIG['normal_day_sign_in']
      receive_message POINTS_CONFIG['normal_day_sign_in'], points_count, I18n.t('controller.session.message.normal_day_sign_in')

      if Time.zone.now.mday == 1
        increase_reload! :points_count, POINTS_CONFIG['first_month_day_sign_in']
        receive_message POINTS_CONFIG['first_month_day_sign_in'], points_count, I18n.t('controller.session.message.first_month_day_sign_in')
      end
    end

    touch :last_signed_in_at
  end
end
