class PostAbility
  attr_reader :current_user, :post

  def initialize(current_user, post)
    @current_user = current_user
    @post = post
  end

  def create?

  end

  def update_node?
    
  end

  def update_title?
    
  end

  def update_content?
    
  end

  def update_extra_info?
    
  end

  def destroy?
    
  end
end