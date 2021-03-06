class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :content
      t.text :extra_info
      t.integer :user_id
      t.integer :node_id
      t.string :permalink
      t.boolean :can_be_deleted, default: true, null: false
      t.integer :highest_bonus_points, default: 0, null: false
      t.integer :views_count, default: 0, null: false
      t.integer :direct_comments_count, default: 0, null: false
      t.integer :total_comments_count, default: 0, null: false
      t.integer :collectors_count, default: 0, null: false
      t.integer :up_voters_count, default: 0, null: false
      t.integer :down_voters_count, default: 0, null: false
      t.datetime :last_commented_at, null: false

      t.timestamps
    end

    add_index :posts, [:created_at, :user_id]
    add_index :posts, [:last_commented_at, :user_id]
    add_index :posts, :permalink, unique: true
  end
end
