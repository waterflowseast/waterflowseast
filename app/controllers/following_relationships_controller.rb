class FollowingRelationshipsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_user, only: :create
  before_filter :authorize_create!, only: :create

  before_filter :find_following_relationship, only: :destroy
  before_filter :authorize_destroy!, only: :destroy

  def create
    current_user.follow! @user
    redirect_to show_followings_user_path(current_user), notice: I18n.t('controller.following_relationship.just_followed', nickname: @user.nickname)
  end

  def destroy
    @user = @following_relationship.followed
    current_user.unfollow! @user
    redirect_to show_followings_user_path(current_user), notice: I18n.t('controller.following_relationship.just_unfollowed', nickname: @user.nickname)
  end

  private

  def find_user
    @user = User.find_by_id params[:followed_id]
    redirect_to show_followings_user_path(current_user), alert: I18n.t('controller.following_relationship.user_not_exist') if @user.nil?
  end

  def authorize_create!
    following_relationship = current_user.following_relationships.build followed_id: @user.id
    ability_result = can? :create, following_relationship, false
    redirect_to show_followings_user_path(current_user), alert: ability_result.description unless ability_result.result
  end

  def find_following_relationship
    @following_relationship = FollowingRelationship.find_by_id params[:id]
    redirect_to show_followings_user_path(current_user), alert: I18n.t('controller.following_relationship.record_not_exist') if @following_relationship.nil?
  end

  def authorize_destroy!
    ability_result = can? :destroy, @following_relationship, false
    redirect_to show_followings_user_path(current_user), alert: ability_result.description unless ability_result.result
  end
end
