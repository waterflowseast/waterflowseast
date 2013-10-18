module PostsHelper
  def highlight_dd_link(matches, name, url_hash)
    matches = matches.respond_to?(:all?) ? matches : [matches]

    if matches.all? {|match| url_hash[match] == params[match] }
      content_tag :dd, link_to(name, url_hash), class: 'active'
    else
      content_tag :dd, link_to(name, url_hash)
    end
  end

  def collect_uncollect_url(post)
    if current_user.has_collected? post
      link_to t('view.post._post_info.uncollect'), collecting_relationship_path(current_user.collecting_relationships.find_by_post_id(post.id)), method: :delete
    else
      link_to t('view.post._post_info.collect'), collecting_relationships_path(post_id: post.id), method: :post
    end
  end

  def render_post_or_comment(votable)
    if votable.instance_of? Post
      render 'posts/post', post: votable
    else
      render 'users/comment', comment: votable
    end
  end

  def raw_render(text)
    raw MarkdownFormatter.render(text)
  end
end
