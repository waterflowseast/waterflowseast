class DestroyCommentWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, comment_id)
    user = User.find_by_id user_id
    comment = Comment.find_by_id comment_id

    user.destroy_comment comment
  end
end
