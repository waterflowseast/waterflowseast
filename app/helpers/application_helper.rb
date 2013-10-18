# coding: utf-8

module ApplicationHelper
  def full_title(title)
    base_title = I18n.t 'helper.application.base_title'
    if title.blank?
      base_title
    else
      "#{title} - #{base_title}"
    end
  end

  def paging(pages)
    will_paginate pages, class: 'pagination', inner_window: 2, outer_window: 0, renderer: WillPaginate::ActionView::FoundationLinkRenderer
  end
end
