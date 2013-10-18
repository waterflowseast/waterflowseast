module UsersHelper
  def avatar_link(user, size = :big)
    link_to avatar_tag(user, size), show_followings_user_path(user)
  end

  def avatar_tag(user, size = :big)
    pixel = pixel_for_size(size)
    image_tag avatar_url(user, size), alt: user.nickname, size: "#{pixel}x#{pixel}"
  end

  def avatar_url(user, size = :big)
    site_avatar_url(user, size) || gravatar_url(user, size)
  end

  def site_avatar_url(user, size = :big)
    size = size.in?([:big, :medium, :small]) ? size : :big
    user.avatar.public_send(size).url
  end

  def gravatar_url(user, size = :big)
    pixel = pixel_for_size(size)
    gravatar_token = Digest::MD5::hexdigest(user.email)
    "http://gravatar.com/avatar/#{gravatar_token}?s=#{pixel}&d=monsterid"
  end

  def pixel_for_size(size)
    case size
    when :small then 32
    when :medium then 64
    else 128
    end
  end

  def admin_or_owner?(object)
    current_user.admin? or owner?(object)
  end

  def owner?(object)
    current_user == object.user
  end

  def follow_unfollow_url(user)
    if current_user.has_followed? user
      link_to t('view.user._user_info.unfollow'), following_relationship_path(current_user.following_relationships.find_by_followed_id(user.id)), method: :delete
    else
      link_to t('view.user._user_info.follow'), following_relationships_path(followed_id: user.id), method: :post
    end
  end
end
