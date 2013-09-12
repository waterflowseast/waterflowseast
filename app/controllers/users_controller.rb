class UsersController < ApplicationController
  def index

  end

  def show_followings
    
  end

  def show_followeds
    
  end

  def show_great_posts
    
  end

  def show_posts
    
  end

  def show_collections
    
  end

  def show_comments
    
  end

  def show_up_votes
    
  end

  def show_down_votes
    
  end

  def show_received_secrets
    
  end

  def show_sent_secrets
    
  end

  def show_messages
    
  end

  def show_sent_invitations
    @sent_invitations = current_user.invitations
    @invitation = current_user.invitations.build
  end
  
  def new
    @user = User.new invitation_token: params[:invitation_token]
    @user.email = @user.invitation.try :receiver_email
  end

  def create
    @user = User.new params[:user].permit(:nickname, :email, :password, :password_confirmation, :invitation_token)
    if @user.save
      sign_in @user
      redirect_to @user, notice: I18n.t("controller.user.signed_in", nickname: @user.nickname)
    else
      render :new
    end
  end

  def change_words

  end

  def update_words
    
  end

  def change_avatar
    
  end

  def update_avatar
    
  end

  def change_password

  end

  def update_password
  
  end

  def destroy
    
  end
end
