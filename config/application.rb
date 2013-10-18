require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

require 'yaml'
POINTS_CONFIG = YAML.load_file File.expand_path('../points_config.yml', __FILE__)
EXTRA_CONFIG = YAML.load_file File.expand_path('../extra_config.yml', __FILE__)

require 'will_paginate'
WillPaginate.per_page = EXTRA_CONFIG['per_page']

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module Waterflowseast
  class Application < Rails::Application
    config.time_zone = 'Beijing'
    config.i18n.default_locale = 'zh-CN'
    config.encoding = "utf-8"

    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.whitelist_attributes = true
    config.assets.enabled = true
    config.assets.version = '1.0'
  end
end
