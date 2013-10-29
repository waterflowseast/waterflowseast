class CommentsController < ApplicationController
  before_filter :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  before_filter :find_commentable_for_new, only: :new
  before_filter :find_commentable_for_create, only: :create
  before_filter :authorize_create!, only: [:new, :create]

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
  end

  def create
    if @ajax_error_description.blank? and @comment.save
      CreateCommentWorker.perform_async current_user.id, @comment.id
      respond_to do |format|
        format.html do
          type = @commentable.instance_of?(Comment) ? I18n.t('controller.comment.is_comment') : I18n.t('controller.comment.is_post')
          redirect_to show_total_comments_post_path(@commentable.original_post), notice: I18n.t('controller.comment.just_created', nickname: @commentable.user.nickname, type: type)
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
    DestroyCommentWorker.perform_async current_user.id, @comment.id
    redirect_to show_total_comments_post_path(original_post), notice: I18n.t('controller.comment.just_destroyed')
  end

  private

  def find_commentable_for_new
    if params[:commentable_type].in? ['Comment', 'Post']
      @commentable = params[:commentable_type].constantize.find_by_id params[:commentable_id]
      redirect_to root_path, alert: I18n.t('controller.comment.commentable_not_exist') if @commentable.nil?
    else
      redirect_to root_path, alert: I18n.t('controller.comment.wrong_class', klass: params[:commentable_type])
    end
  end

  def find_commentable_for_create
    if params[:comment][:commentable_type].in? ['Comment', 'Post']
      @commentable = params[:comment][:commentable_type].constantize.find_by_id params[:comment][:commentable_id]
      redirect_to root_path, alert: I18n.t('controller.comment.commentable_not_exist') if @commentable.nil?
    else
      redirect_to root_path, alert: I18n.t('controller.comment.wrong_class', klass: params[:comment][:commentable_type])
    end
  end

  def authorize_create!
    content = params[:comment].respond_to?(:[]) ? params[:comment][:content] : nil
    @comment = current_user.comments.build commentable: @commentable, content: content

    ability_result = can? :create, @comment, false
    unless ability_result.result
      respond_to do |format|
        format.html { redirect_to show_total_comments_post_path(@commentable.original_post), alert: ability_result.description }
        format.js { @comment.errors.add :base, (@ajax_error_description = ability_result.description) }
      end
    end
  end

  def find_comment
    @comment = Comment.find_by_permalink params[:id]
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
