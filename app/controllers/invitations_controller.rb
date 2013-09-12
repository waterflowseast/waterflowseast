class InvitationsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authorize_create!
  
  def create
    if @invitation.save
      current_user.send_invitation(@invitation)
      redirect_to show_sent_invitations_user_path(current_user), notice: I18n.t('controller.invitation.just_invited', email: @invitation.receiver_email)
    else
      @sent_invitations = current_user.invitations
      render 'users/show_sent_invitations'
    end
  end

  private

  def authorize_create!
    @invitation = current_user.invitations.build params[:invitation].permit(:receiver_email)
    ability_result = can? :create, @invitation, false
    redirect_to show_sent_invitations_user_path(current_user), alert: ability_result.description unless ability_result.result
  end
end
