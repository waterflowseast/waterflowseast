class PostsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show_direct_comments, :show_total_comments, :show_collectors, :show_up_voters, :show_down_voters]

  before_filter :find_post, except: [:index, :new, :create]
  # won't increase views_count when people enter actions like :show_collectors, :show_up_voters and :show_down_voters, because I think people enter those actions not for viewing the post
  before_filter :increment_views_count, only: [:show_direct_comments, :show_total_comments]
  before_filter :authorize_create!, only: :create

  before_filter :authorize_update_except_for_content!, only: [:change_node, :update_node, :change_title, :update_title, :change_extra_info, :update_extra_info]
  before_filter :authorize_update_content!, only: [:change_content, :update_content]
  before_filter :authorize_destroy!, only: :destroy

  def index
    @posts = Post.reorder('')
    @posts = @posts.search(params[:serach]) if params[:search]
    @posts = @posts.select_hot(params[:hot]) if params[:hot]
    @posts = @posts.select_time(params[:time]) if params[:time]

    if params[:node]
      @posts = @posts.select_node params[:node]
    elsif params[:node_group]
      @posts = @posts.select_node_group params[:node_group]
    end

    @posts = @posts.order('posts.updated_at DESC')
    @posts = @posts.paginate(page: params[:page])
  end

  def show_direct_comments
    @direct_comments = @post.comments.paginate page: params[:page]
  end

  def show_total_comments
    @total_comments = @post.comments.paginate page: params[:page]
  end

  def show_collectors
    @collectors = @post.collectors.paginate page: params[:page]
  end

  def show_up_voters
    @up_voters = @post.up_voters.paginate page: params[:page]
  end

  def show_down_voters
    @down_voters = @post.down_voters.paginate page: params[:page]
  end

  def new
    @post = current_user.posts.build
  end

  def create
    if @post.save
      current_user.has_created_post(@post)
      redirect_to show_direct_comments_post_path(@post), notice: I18n.t('controller.post.just_created')
    else
      render :new
    end
  end

  def change_node
  end

  def update_node
    if @post.update_attributes params[:post].permit(:node_id)
      redirect_to show_direct_comments_post_path(@post), notice: I18n.t('controller.post.update_node')
    else
      render :change_node
    end
  end

  def change_title
  end

  def update_title
    if @post.update_attributes params[:post].permit(:title)
      redirect_to show_direct_comments_post_path(@post), notice: I18n.t('controller.post.update_title')
    else
      render :change_title
    end
  end

  def change_content
  end

  def update_content
    if @post.update_attributes params[:post].permit(:content)
      redirect_to show_direct_comments_post_path(@post), notice: I18n.t('controller.post.update_content')
    else
      render :change_content
    end
  end

  def change_extra_info
  end

  def update_extra_info
    if @post.update_attributes params[:post].permit(:extra_info)
      redirect_to show_direct_comments_post_path(@post), notice: I18n.t('controller.post.update_extra_info')
    else
      render :change_extra_info
    end
  end

  def destroy
    post_user = @post.user
    current_user.destroy_post(@post)
    redirect_to show_posts_user_path(post_user), notice: I18n.t('controller.post.just_destroyed')
  end

  private

  def find_post
    @post = Post.find params[:id]
    redirect_to root_path, alert: I18n.t('controller.post.not_exist') if @post.nil?
  end

  def increment_views_count
    # views_count increases only when people hit the first page of comments
    # it is possible that people enter this before_filter at the same time, and @post.increment!(:views_count) is not guaranteed to do it right, so I went another way
    Post.increment_counter :views_count, @post.id if params[:page].nil?
  end

  def authorize_create!
    @post = current_user.posts.build params[:post].permit(:node_id, :title, :content)
    ability_result = can? :create, @post, false
    redirect_to show_posts_user_path(current_user), alert: ability_result.description unless ability_result.result
  end

  def authorize_update_except_for_content!
    ability_result = can? :update_except_for_content, @post, false
    redirect_to show_direct_comments_post_path(@post), alert: ability_result.description unless ability_result.result
  end

  def authorize_update_content!
    ability_result = can? :update_content, @post, false
    redirect_to show_direct_comments_post_path(@post), alert: ability_result.description unless ability_result.result
  end

  def authorize_destroy!
    ability_result = can? :destroy, @post, false
    redirect_to show_direct_comments_post_path(@post), alert: ability_result.description unless ability_result.result
  end
end
