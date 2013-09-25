class Admin::NodesController < Admin::ApplicationController
  before_filter :find_node, only: [:edit, :update]

  def new
    @node = Node.new
  end

  def create
    @node = Node.new params[:node].permit(:name, :position_text, :node_group_id)

    if @node.save
      redirect_to admin_node_groups_path, notice: I18n.t('controller.admin.node.just_created', node_group: @node.node_group.name, node: @node.name)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @node.update_attributes params[:node].permit(:name, :position_text, :node_group_id)
      redirect_to admin_node_groups_path, notice: I18n.t('controller.admin.node.just_updated')
    else
      render :edit
    end
  end

  private

  def find_node
    @node = Node.find params[:id]
    redirect_to root_path, alert: I18n.t('controller.admin.node.not_exist') if @node.nil?
  end
end
