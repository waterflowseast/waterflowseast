class Notifier < ActionMailer::Base
  default from: "no-reply@WaterFlowsEast.com"

  def send_invitation(invitation)
    @invitation = invitation

    mail to: @invitation.receiver_email
  end

  def send_email_confirm(user)
    @user = user

    mail to: @user.email
  end

  def send_password_reset(user)
    @user = user

    mail to: @user.email
  end
end
