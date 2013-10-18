module InvitationsHelper
  def invitation_receiver_display(invitation)
    user = User.find_by_email invitation.receiver_email
    receiver = if user.nil? then nil
               elsif user.invitation_id == invitation.id then user
               else nil
               end
        
    if receiver
      link_to receiver.nickname, show_followings_user_path(receiver)
    else
      '-'
    end
  end
end
