module ActiveSupport
  class HashWithIndifferentAccess
    # this is just a super simple method to filter params, nested keys not supported
    def permit(*args)
      permitted_keys = args.map(&:to_sym) & keys.map(&:to_sym)
      permitted_hash = self.class.new

      permitted_keys.each do |key|
        permitted_hash[key] = fetch key
      end

      permitted_hash
    end
  end
end
