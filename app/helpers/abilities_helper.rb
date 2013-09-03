module AbilitiesHelper
  def can?(action, record_or_class)
    if record_or_class.instance_of? Class
      klass = record_or_class
      record = record_or_class.new
    else
      klass = record_or_class.class
      record = record_or_class
    end

    new_ability = "#{klass}Ability".constantize.new(current_user, record)
    new_ability.public_send("#{action.to_s}?")
  end
end