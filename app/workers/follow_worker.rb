class FollowWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, other_user_id)
    user = User.find_by_id user_id
    other_user = User.find_by_id other_user_id

    # you follow people, your points will be subtracted and system will send you a message
    user.increase_reload! :points_count, POINTS_CONFIG['follow']
    user.receive_message POINTS_CONFIG['follow'], user.points_count, I18n.t('controller.following_relationship.message.points_subtraction', nickname: other_user.nickname)

    # the one you just followed, his points will be added and system will send him a message
    other_user.increase_reload! :points_count, POINTS_CONFIG['be_followed']
    other_user.receive_message POINTS_CONFIG['be_followed'], other_user.points_count, I18n.t('controller.following_relationship.message.points_addition', nickname: user.nickname)

    # those people who followed you will receive a message from the system
    user.followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.following_relationship.message.to_followeds', name_a: user.nickname, name_b: other_user.nickname)
    end

    # update corresponding count
    other_user.increase! :followeds_count
  end
end
