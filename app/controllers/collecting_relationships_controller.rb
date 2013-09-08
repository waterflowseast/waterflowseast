class CollectingRelationshipsController < ApplicationController
  before_filter :authenticate_user!

  before_filter :find_post, only: :create
  before_filter :authorize_create!, only: :create

  before_filter :find_collecting_relationship, only: :destroy
  before_filter :authorize_destroy!, only: :destroy

  def create
    current_user.collect! @post
    redirect_to show_collections_user_path(current_user), notice: I18n.t('controller.collecting_relationship.just_collected', nickname: @post.user.nickname)
  end

  def destroy
    @post = @collecting_relationship.post
    current_user.uncollect! @post
    redirect_to show_collections_user_path(current_user), notice: I18n.t('controller.collecting_relationship.just_uncollected', nickname: @post.user.nickname)
  end

  private

  def find_post
    @post = Post.find_by_id params[:post_id]
    redirect_to show_collections_user_path(current_user), alert: I18n.t('controller.collecting_relationship.post_not_exist') if @post.nil?
  end

  def authroize_create!
    collecting_relationship = current_user.collecting_relationships.build post_id: @post.id
    ability_result = can? :create, collecting_relationship, false
    redirect_to show_collections_user_path(current_user), alert: ability_result.description unless ability_result.result
  end

  def find_collecting_relationship
    @collecting_relationship = CollectingRelationship.find_by_id params[:id]
    redirect_to show_collections_user_path(current_user), alert: I18n.t('controller.collecting_relationship.record_not_exist') if @collecting_relationship.nil?
  end

  def authorize_destroy!
    ability_result = can? :destroy, @collecting_relationship, false
    redirect_to show_collections_user_path(current_user), alert: ability_result.description unless ability_result.result
  end
end
