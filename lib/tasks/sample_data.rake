# coding: utf-8

namespace :db do
  desc "Create following_relatioships, posts, collecting_relationships, comments, voting_up_relationships, voting_down_relationships"
  task :sample_data => :environment do
    output = `ps aux | grep sidekiq | grep -v grep | wc -l`
    raise '你未运行 sidekiq，请在终端中输入命令 bundle exec sidekiq 来运行它' if output.to_i == 0

    # ---------------- creating following_relationships ----------------
    puts "creating following_relatioships".center(100, '-') + "\n\n"

    User.all.each do |follower|
      User.all.sample(rand 10).each do |followed|
        follower.follow! followed if (follower != followed) and ! follower.has_followed?(followed)
      end
    end

    sleep 10

    # ---------------- creating posts ----------------
    puts "creating posts".center(100, '-') + "\n\n"

    User.all.each do |user|
      rand(3).times do |n|
        post = user.posts.create title: "post #{n+1} by #{user.nickname}", 
          content: "# POST NO.#{n+1}\nMy name is #{user.nickname}\n---\n\n---\n\n## and my email is #{user.email}", 
          node_id: Node.pluck(:id).sample
        CreatePostWorker.perform_async user.id, post.id
      end
    end

    sleep 10

    # ---------------- creating collecting_relationships ----------------
    puts "creating collecting_relationships".center(100, '-') + "\n\n"

    collected_posts_max = Post.count / 5
    User.all.each do |user|
      Post.all.sample(rand collected_posts_max).each do |post|
        user.collect! post if (user != post.user) and ! user.has_collected?(post)
      end
    end

    sleep 10

    # ---------------- creating comments ----------------
    puts "creating comments".center(100, '-') + "\n\n"

    Post.all.each do |post|
      User.all.sample(rand 10).each do |user1|
        comm1 = user1.comments.create commentable: post, content: "Nested Level 1, created by #{user1.nickname}"
        CreateCommentWorker.perform_async user1.id, comm1.id
        User.all.sample(rand 6).each do |user2|
          comm2 = user2.comments.create commentable: comm1, content: "Nested Level 2, created by #{user2.nickname}"
          CreateCommentWorker.perform_async user2.id, comm2.id
          User.all.sample(rand 5).each do |user3|
            comm3 = user3.comments.create commentable: comm2, content: "Nested Level 3, created by #{user3.nickname}"
            CreateCommentWorker.perform_async user3.id, comm3.id
            User.all.sample(rand 4).each do |user4|
              comm4 = user4.comments.create commentable: comm3, content: "Nested Level 4, created by #{user4.nickname}"
              CreateCommentWorker.perform_async user4.id, comm4.id
              User.all.sample(rand 3).each do |user5|
                comm5 = user5.comments.create commentable: comm4, content: "Nested Level 5, created by #{user5.nickname}"
                CreateCommentWorker.perform_async user5.id, comm5.id
              end
            end
          end
        end
      end
    end

    sleep 100

    # ---------------- creating votes for posts ----------------
    puts "creating votes for posts".center(100, '-') + "\n\n"

    Post.all.each do |post|
      User.all.sample(rand 10).each do |user|
        if (user != post.user) and ! user.has_voted?(post)
          rand(1000) > 500 ? user.vote_up!(post) : user.vote_down!(post)
        end
      end
    end

    sleep 10

    # ---------------- creating votes for comments ------------
    puts "creating votes for comments".center(100, '-') + "\n\n"

    voted_comments_count = Comment.count / 3
    Comment.all.sample(voted_comments_count).each do |comment|
      User.all.sample(rand 10).each do |user|
        if (user != comment.user) and ! user.has_voted?(comment)
          rand(1000) > 500 ? user.vote_up!(comment) : user.vote_down!(comment)
        end
      end
    end
  end
end
