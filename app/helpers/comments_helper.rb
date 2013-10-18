module CommentsHelper
  def direct_comments(comments)
    comments.map do |comment|
      render(comment) + content_tag(:div, nil, class: 'nested-comments')
    end.join.html_safe
  end

  def nested_comments(comments)
    comments.map do |comment; sub_comments|
      sub_comments = (comment.total_comments_count > 0) ? comment.comments : []
      render(comment) + content_tag(:div, nested_comments(sub_comments), class: 'nested-comments')
    end.join.html_safe
  end
end
