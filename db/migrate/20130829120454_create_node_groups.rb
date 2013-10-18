class CreateNodeGroups < ActiveRecord::Migration
  def change
    create_table :node_groups do |t|
      t.string :name
      t.integer :position, default: 100, null: false
      t.string :permalink

      t.timestamps
    end

    add_index :node_groups, :name
    add_index :node_groups, :position
    add_index :node_groups, :permalink, unique: true
  end
end
