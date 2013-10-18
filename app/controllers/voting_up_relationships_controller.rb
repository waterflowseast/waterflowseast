class VotingUpRelationshipsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_votable
  before_filter :authorize_create!

  def create
    current_user.vote_up! @votable
    redirect_to show_up_votes_user_path(current_user), notice: I18n.t('controller.voting_up_relationship.just_voted_up', nickname: @votable.user.nickname)
  end

  private
  
  def find_votable
    if params[:votable_type].in? ['Post', 'Comment']
      @votable = params[:votable_type].constantize.find_by_id params[:votable_id]
      redirect_to show_up_votes_user_path(current_user), alert: I18n.t('controller.voting_up_relationship.votable_not_exist') if @votable.nil?
    else
      redirect_to show_up_votes_user_path(current_user), alert: I18n.t('controller.voting_up_relationship.wrong_class', klass: params[:votable_type])
    end
  end

  def authorize_create!
    voting_up_relationship = current_user.voting_up_relationships.build votable: @votable
    ability_result = can? :create, voting_up_relationship, false
    redirect_to show_up_votes_user_path(current_user), alert: ability_result.description unless ability_result.result
  end
end
