# coding: utf-8

module ApplicationHelper
  def full_title(title)
    base_title = I18n.t 'base_title'
    if title.blank?
      base_title
    else
      "#{title} - #{base_title}"
    end
  end
end
