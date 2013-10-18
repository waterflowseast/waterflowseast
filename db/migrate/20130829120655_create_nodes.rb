class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes do |t|
      t.string :name
      t.integer :position, default: 100, null: false
      t.integer :node_group_id
      t.string :permalink

      t.timestamps
    end

    add_index :nodes, :name
    add_index :nodes, [:node_group_id, :position]
    add_index :nodes, :permalink, unique: true
  end
end
