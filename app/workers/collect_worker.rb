class CollectWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, post_id)
    user = User.find_by_id user_id
    post = Post.find_by_id post_id
    post_user = post.user

    # you collect others' posts, your points will be subtracted and system will send you a message
    user.increase_reload! :points_count, POINTS_CONFIG['collect']
    user.receive_message POINTS_CONFIG['collect'], user.points_count, I18n.t('controller.collecting_relationship.message.points_subtraction', nickname: post_user.nickname, title: post.title)

    # the one whose post you just collected, his points will be added and system will send him a message
    post_user.increase_reload! :points_count, POINTS_CONFIG['be_collected']
    post_user.receive_message POINTS_CONFIG['be_collected'], post_user.points_count, I18n.t('controller.collecting_relationship.message.points_addition', nickname: user.nickname, title: post.title)

    # those people who followed you will receive a message from the system
    user.followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.collecting_relationship.message.to_followeds', name_a: user.nickname, name_b: post_user.nickname, title: post.title)
    end

    # update corresponding count
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
      post_user.receive_message bonus_points, post_user.points_count, I18n.t('controller.collecting_relationship.message.bonus', title: post.title, count: post.collectors_count, bonus: bonus_points)

      user_inviter = post_user.inviter
      if user_inviter
        user_inviter.increase_reload! :points_count, bonus_points
        user_inviter.receive_message bonus_points, user_inviter.points_count, I18n.t('controller.collecting_relationship.message.inviter_bonus', name: post_user.nickname, title: post.title, count: post.collectors_count, bonus: bonus_points)
      end
    end
  end
end
