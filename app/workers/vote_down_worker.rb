class VoteDownWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, votable_type, votable_id)
    user = User.find_by_id user_id
    votable = votable_type.constantize.public_send :find_by_id, votable_id
    votable_user = votable.user

    # you vote down others' posts or comments, your points will be subtracted and system will send you a message
    user.increase_reload! :points_count, POINTS_CONFIG['vote_down']
    user.receive_message POINTS_CONFIG['vote_down'], user.points_count, I18n.t('controller.voting_down_relationship.message.points_subtraction', nickname: votable_user.nickname)

    # the one whose post or comment you just voted down, system will send him a message
    votable_user.receive_message 0, votable_user.points_count, I18n.t('controller.voting_down_relationship.message.warning', nickname: user.nickname)

    # those people who followed you will receive a message from the system
    user.followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.voting_down_relationship.message.to_followeds', name_a: user.nickname, name_b: votable_user.nickname)
    end

    # update corresponding count
    votable.increase! :down_voters_count
  end
end
