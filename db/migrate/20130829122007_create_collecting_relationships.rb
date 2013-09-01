class CreateCollectingRelationships < ActiveRecord::Migration
  def change
    create_table :collecting_relationships do |t|
      t.integer :post_id
      t.integer :user_id

      t.timestamps
    end

    add_index :collecting_relationships, :post_id
    add_index :collecting_relationships, :user_id
    add_index :collecting_relationships, [:post_id, :user_id], unique: true
  end
end
