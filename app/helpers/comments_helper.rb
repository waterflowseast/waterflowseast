module CommentsHelper
  def direct_comments(comments)
    comments.map {|comment| render comment}.join.html_safe
  end

  def nested_comments(comments)
    comments.map do |comment; result|
      result = render comment
      result << content_tag(:div, nested_comments(comment.comments), class: 'nested_comments') if comment.total_comments_count > 0
      result
    end.join.html_safe
  end
end
