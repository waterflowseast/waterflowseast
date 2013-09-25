class UsersController < ApplicationController
  before_filter :authenticate_user!, except: [:new, :create]

  before_filter :find_user, except: [:index, :new, :create]
  before_filter :authorize_show_private!, only: [:show_received_secrets, :show_sent_secrets, :show_messages, :show_sent_invitations]
  before_filter :authorize_update_private!, only: [:change_words, :update_words, :change_avatar, :update_avatar, :change_password, :update_password]
  before_filter :authorize_destroy!, only: :destroy

  def index
    @users = User.available_users

    if params[:search]
      @users = @users.search params[:search]
    else
      @users = @users.select_sort params[:sort]
    end

    @users = @users.paginate page: params[:page]
  end

  def show_followings
    @followings = @user.followings.order('following_relationships.created_at DESC').paginate page: params[:page]
  end

  def show_followeds
    @followeds = @user.followeds.order('following_relationships.created_at DESC').paginate page: params[:page]
  end

  def show_great_posts
    @great_posts = @user.posts.where(posts: { can_be_deleted: false }).reorder('posts.created_at DESC').paginate page: params[:page]
  end

  def show_posts
    @posts = @user.posts.reorder('posts.created_at DESC').paginate page: params[:page]
  end

  def show_collections
    @collections = @user.collections.order('collecting_relationships.created_at DESC').paginate page: params[:page]
  end

  def show_comments
    @comments = @user.comments.reorder('comments.created_at DESC').paginate page: params[:page]
  end

  def show_up_votes
    @up_votes = @user.voting_up_relationships.includes(:votable).order('voting_up_relationships.created_at DESC').paginate(page: params[:page]).map(&:votable)
  end

  def show_down_votes
    @down_votes = @user.voting_down_relationships.includes(:votable).order('voting_down_relationships.created_at DESC').paginate(page: params[:page]).map(&:votable)
  end

  def show_received_secrets
    @received_secrets = @user.available_received_secrets.paginate page: params[:page]
  end

  def show_sent_secrets
    @sent_secrets = @user.available_sent_secrets.paginate page: params[:page]
  end

  def show_messages
    @messages = @user.messages.paginate page: params[:page]
  end

  def show_sent_invitations
    @invitation = @user.invitations.build
    @sent_invitations = @user.invitations.paginate page: params[:page]
  end
  
  def new
    @user = User.new invitation_token: params[:invitation_token]
    @user.email = @user.invitation.try :receiver_email
  end

  def create
    @user = User.new params[:user].permit(:nickname, :email, :password, :password_confirmation, :invitation_token)
    if @user.save
      @user.send_email_confirm
      redirect_to root_path, notice: I18n.t('controller.user.confirm_now', email: @user.email, time_limit: EXTRA_CONFIG['confirm_out_of_time_in_hours'])
    else
      render :new
    end
  end

  def change_words
  end

  def update_words
    if @user.update_attributes params[:user].permit(:words)
      redirect_to show_followings_user_path(@user), notice: I18n.t('controller.user.update_words')
    else
      render :change_words
    end
  end

  def change_avatar
  end

  def update_avatar
    if @user.update_attributes params[:user].permit(:avatar)
      redirect_to show_followings_user_path(@user), notice: I18n.t('controller.user.update_avatar')
    else
      render :change_avatar
    end
  end

  def change_password
  end

  def update_password
    if @user.update_attributes params[:user].permit(:password, :password_confirmation)
      sign_in @user
      redirect_to show_followings_user_path(@user), notice: I18n.t('controller.user.update_password')
    else
      render :change_password
    end
  end

  def destroy
    @user.destroy_self
    redirect_to root_path, notice: I18n.t('controller.user.just_destroyed', nickname: @user.nickname)
  end

  private

  def find_user
    @user = User.available_users.find params[:id]
    redirect_to users_path, alert: I18n.t('controller.user.not_exist') if @user.nil?
  end

  def authorize_show_private!
    ability_result = can? :show_private, @user, false
    redirect_to show_followings_user_path(current_user), alert: ability_result.description unless ability_result.result
  end

  def authorize_update_private!
    ability_result = can? :update_private, @user, false
    redirect_to show_followings_user_path(current_user), alert: ability_result.description unless ability_result.result
  end

  def authorize_destroy!
    ability_result = can? :destroy, @user, false
    redirect_to show_followings_user_path(current_user), alert: ability_result.description unless ability_result.result
  end
end
