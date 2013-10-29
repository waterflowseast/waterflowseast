class SendInvitationWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(invitation_id)
    sent_invitation = Invitation.find_by_id invitation_id
    Notifier.send_invitation(sent_invitation).deliver
  end
end
