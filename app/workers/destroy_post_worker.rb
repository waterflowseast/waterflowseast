class DestroyPostWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, post_id)
    user = User.find_by_id user_id
    post = Post.find_by_id post_id

    user.destroy_post post
  end
end
