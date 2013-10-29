class VoteUpWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, votable_type, votable_id)
    user = User.find_by_id user_id
    votable = votable_type.constantize.public_send :find_by_id, votable_id
    votable_user = votable.user

    # you vote up others' posts or comments, your points will be subtracted and system will send you a message
    user.increase_reload! :points_count, POINTS_CONFIG['vote_up']
    user.receive_message POINTS_CONFIG['vote_up'], user.points_count, I18n.t('controller.voting_up_relationship.message.points_subtraction', nickname: votable_user.nickname)

    # the one whose post or comment you just voted up, his points will be added and system will send him a message
    votable_user.increase_reload! :points_count, POINTS_CONFIG['be_voted_up']
    votable_user.receive_message POINTS_CONFIG['be_voted_up'], votable_user.points_count, I18n.t('controller.voting_up_relationship.message.points_addition', nickname: user.nickname)

    # those people who followed you will receive a message from the system
    user.followeds.each do |u|
      u.receive_message 0, u.points_count, I18n.t('controller.voting_up_relationship.message.to_followeds', name_a: user.nickname, name_b: votable_user.nickname)
    end

    # update corresponding count
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
end
