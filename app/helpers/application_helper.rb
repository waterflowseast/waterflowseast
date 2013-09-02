# coding: utf-8

module ApplicationHelper
  def full_title(title)
    base_title = "Ruby平台的Web开发"
    if title.blank?
      base_title
    else
      "#{title} - #{base_title}"
    end
  end
end
