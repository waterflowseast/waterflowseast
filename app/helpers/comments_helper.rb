module CommentsHelper
  def direct_comments(comments)
    comments.map do |comment|
      render(comment) + content_tag(:div, nil, class: 'nested-comments')
    end.join.html_safe
  end

  def nested_comments(comments)
    comments.map do |comment|
      if comment.total_comments_count > 0
        render(comment) + content_tag(:div, nested_comments(comment.comments), class: 'nested-comments')
      else
        render(comment) + content_tag(:div, nil, class: 'nested-comments')
      end
    end.join.html_safe
  end
end
