module AbilitiesHelper
  def can?(action, record_or_class, just_boolean = true)
    if record_or_class.instance_of? Class
      klass = record_or_class
      record = record_or_class.new
    else
      klass = record_or_class.class
      record = record_or_class
    end

    new_ability = "#{klass}Ability".constantize.new(current_user, record)
    ability_result = new_ability.public_send("#{action.to_s}?")

    if just_boolean
      ability_result.result
    else
      ability_result
    end
  end

  def cannot?(action, record_or_class)
    ! can?(action, record_or_class)
  end
end