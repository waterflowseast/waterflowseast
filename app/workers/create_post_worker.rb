class CreatePostWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user_id, post_id)
    user = User.find_by_id user_id
    post = Post.find_by_id post_id

    user.has_created_post post
  end
end
