# coding: utf-8

module Waterflowseast
  module Regex
    def self.nickname
      /\A[\p{Han}a-z][\p{Han}\w\.\-]{1,14}[\p{Han}a-z0-9]\z/i
    end

    def self.email
      @email_regex ||= begin
        email_name_regex  = '[A-Z0-9_\.%\+\-\']+'
        domain_head_regex = '(?:[A-Z0-9\-]+\.)+'
        domain_tld_regex  = '(?:[A-Z]{2,4}|museum|travel|онлайн)'
        /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
      end
    end

    def self.video
      %r{!v<a href="([^">]*)">[^<]*</a>}
    end
  end
end
