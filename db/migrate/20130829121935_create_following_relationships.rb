class CreateFollowingRelationships < ActiveRecord::Migration
  def change
    create_table :following_relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end

    add_index :following_relationships, :follower_id
    add_index :following_relationships, :followed_id
    add_index :following_relationships, [:follower_id, :followed_id], unique: true
  end
end
