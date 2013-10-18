# coding: utf-8

namespace :db do
  desc 'Create all the node_groups and nodes'
  task :nodes => :environment do
    raise '数据库中已经有 NodeGroup 的记录了' if NodeGroup.count > 0

    NODES = YAML.load_file (Rails.root + 'lib/tasks/nodes.yml')
    node_group_position = 3

    NODES.each do |bundle|
      puts "\n" + bundle['node_group'].center(EXTRA_CONFIG['node_group_name_max'], '-')
      node_group_id = NodeGroup.create(name: bundle['node_group'], position_text: node_group_position).id
      node_position = 3

      bundle['node'].each do |node_name|
        puts node_name.center(EXTRA_CONFIG['node_name_max'])
        Node.create name: node_name, position_text: node_position, node_group_id: node_group_id
        node_position += 3
      end

      node_group_position += 3
    end
  end
end
