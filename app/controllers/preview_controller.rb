class PreviewController < ApplicationController
  # below is the reason why I didn't write :authenticate_user! before_filter
  #
  # suppose we have written this before_filter, and one user have opened a lot of pages including one page (let's call it page A) 
  # which he had ajaxed the comment function but had not posted it. now on another page he signed out, then back to page A, ready to preview.
  # when he click the preview button, it's not gonna work because of the before_filter.
  # Here the problem goes: if you check the development log, you'll see lots of SQLs there trying to find the current user who is nil now.
  #
  # I haven't figured it out why this happens and still have no solution for that, so I decided to ignore the before_filter.
  # I will fix this when I find an elegant way to solve that.

  def create
    render text: MarkdownFormatter.render(params[:preview_content])
  end
end
