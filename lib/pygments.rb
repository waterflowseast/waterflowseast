module Pygments
  def self.find_lexer(language)
    Lexer.find(language)
  end
end
