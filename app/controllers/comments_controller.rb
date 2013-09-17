class CommentsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  before_filter :find_commentable_for_new, only: :new
  before_filter :find_commentable_for_create, only: :create
  before_filter :authorize_create!, only: :create

  before_filter :find_comment, except: [:new, :create]
  before_filter :authorize_update!, only: [:edit, :update]
  before_filter :authorize_destroy!, only: :destroy

  def show_total_comments
    @total_comments = @comment.comments.paginate page: params[:page]
  end

  def show_up_voters
    @up_voters = @comment.up_voters.paginate page: params[:page]
  end

  def show_down_voters
    @down_voters = @comment.down_voters.paginate page: params[:page]
  end

  def new
    @comment = current_user.comments.build commentable: @commentable
  end

  def create
    if @comment.save
      current_user.has_created_comment(@comment)
      respond_to do |format|
        format.html do
          type = @commentable.instance_of?(Comment) ? I18n.t('controller.comment.is_comment') : I18n.t('controller.comment.is_post')
          redirect_to show_direct_comments_post_path(@commentable.original_post), notice: I18n.t('controller.comment.just_created', nickname: @commentable.user.nickname, type: type)
        end
        format.js
      end
    else
      respond_to do |format|
        format.html { render :new }
        format.js
      end
    end
  end

  def edit
  end

  def update
    if @comment.update_attributes params[:comment].permit(:content)
      redirect_to show_total_comments_comment_path(@comment), notice: I18n.t('controller.comment.just_updated')
    else
      render :edit
    end
  end

  def destroy
    original_post = @comment.original_post
    current_user.destroy_comment(@comment)
    redirect_to show_direct_comments_post_path(original_post), notice: I18n.t('controller.comment.just_destroyed')
  end

  private

  def find_commentable_for_new
    redirect_to root_path, alert: I18n.t('controller.comment.wrong_class', klass: params[:commentable_type]) unless params[:commentable_type].in? ['Comment', 'Post']
    @commentable = params[:commentable_type].constantize.find_by_id params[:commentable_id]
    redirect_to root_path, alert: I18n.t('controller.comment.commentable_not_exist') if @commentable.nil?
  end

  def find_commentable_for_create
    redirect_to root_path, alert: I18n.t('controller.comment.wrong_class', klass: params[:comment][:commentable_type]) unless params[:comment][:commentable_type].in? ['Comment', 'Post']
    @commentable = params[:comment][:commentable_type].constantize.find_by_id params[:comment][:commentable_id]
    redirect_to root_path, alert: I18n.t('controller.comment.commentable_not_exist') if @commentable.nil?
  end

  def authorize_create!
    @comment = current_user.comments.build commentable: @commentable, content: params[:comment][:content]
    ability_result = can? :create, @comment, false
    redirect_to show_direct_comments_post_path(@commentable.original_post), alert: ability_result.description unless ability_result.result
  end

  def find_comment
    @comment = Comment.find params[:id]
    redirect_to root_path, alert: I18n.t('controller.comment.not_exist') if @comment.nil?
  end

  def authorize_update!
    ability_result = can? :update, @comment, false
    redirect_to show_total_comments_comment_path(@comment), alert: ability_result.description unless ability_result.result
  end

  def authorize_destroy!
    ability_result = can? :destroy, @comment, false
    redirect_to show_total_comments_comment_path(@comment), alert: ability_result.description unless ability_result.result
  end
end
