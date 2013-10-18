module Waterflowseast
  module TokenGenerator
    private
    
    def generate_token(column)
      self[column] = loop do
        token = SecureRandom.urlsafe_base64
        break token unless self.class.exists? column => token
      end
    end
  end
end
