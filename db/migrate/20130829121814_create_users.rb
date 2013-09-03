class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :nickname
      t.string :email
      t.string :password_digest
      t.string :remember_token
      t.string :avatar
      t.string :words
      t.boolean :admin, default: false, null: false
      t.string :permalink
      t.boolean :can_be_deleted, default: true, null: false
      t.string :reset_token
      t.datetime :reset_deadline
      t.string :confirm_token
      t.datetime :signed_up_confirmed_at
      t.datetime :last_signed_in_at
      t.integer :invitation_id
      t.integer :followings_count, default: 0, null: false
      t.integer :followeds_count, default: 0, null: false
      t.integer :great_posts_count, default: 0, null: false
      t.integer :posts_count, default: 0, null: false
      t.integer :collections_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false
      t.integer :voting_ups_count, default: 0, null: false
      t.integer :voting_downs_count, default: 0, null: false
      t.integer :received_secrets_count, default: 0, null: false
      t.integer :sent_secrets_count, default: 0, null: false
      t.integer :messages_count, default: 0, null: false
      t.integer :sent_invitations_count, default: 0, null: false
      t.integer :points_count, default: 30, null: false

      t.timestamps
    end

    add_index :users, :nickname, unique: true
    add_index :users, :email, unique: true
    add_index :users, :remember_token, unique: true
    add_index :users, :permalink, unique: true
    add_index :users, :reset_token, unique: true
    add_index :users, :confirm_token, unique: true
    add_index :users, :signed_up_confirmed_at
    add_index :users, :last_signed_in_at
    add_index :users, :followeds_count
    add_index :users, :great_posts_count
    add_index :users, :posts_count
    add_index :users, :points_count
  end
end
