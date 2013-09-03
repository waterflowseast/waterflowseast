class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.text :content
      t.integer :user_id
      t.string :floor
      t.string :permalink
      t.boolean :can_be_deleted, default: true, null: false
      t.integer :total_comments_count, default: 0, null: false
      t.integer :voting_ups_count, default: 0, null: false
      t.integer :voting_downs_count, default: 0, null: false

      t.timestamps
    end

    add_index :comments, [:created_at, :commentable_id, :commentable_type], name: "index_comments_on_created_at_and_commentable"
    add_index :comments, [:created_at, :user_id]
    add_index :comments, :permalink, unique: true
  end
end
