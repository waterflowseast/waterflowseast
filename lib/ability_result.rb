# coding: utf-8

class AbilityResult
  attr_reader :result, :description

  def initialize(result, description = I18n.t('ability.true'))
    @result = result
    @description = description
  end
end
