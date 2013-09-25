class Admin::NodeGroupsController < Admin::ApplicationController
  before_filter :find_node_group, only: [:edit, :update]

  def index
    @node_groups = NodeGroup.includes(:nodes)
  end

  def new
    @node_group = NodeGroup.new
  end

  def create
    @node_group = NodeGroup.new params[:node_group].permit(:name, :position_text)

    if @node_group.save
      redirect_to admin_node_groups_path, notice: I18n.t('controller.admin.node_group.just_created', node_group: @node_group.name)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @node_group.update_attributes params[:node_group].permit(:name, :position_text)
      redirect_to admin_node_groups_path, notice: I18n.t('controller.admin.node_group.just_updated')
    else
      render :edit
    end
  end

  private

  def find_node_group
    @node_group = NodeGroup.find params[:id]
    redirect_to root_path, alert: I18n.t('controller.admin.node_group.not_exist') if @node_group.nil?
  end
end
