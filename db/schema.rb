# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130829122515) do

  create_table "collecting_relationships", :force => true do |t|
    t.integer  "post_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "collecting_relationships", ["post_id", "user_id"], :name => "index_collecting_relationships_on_post_id_and_user_id", :unique => true
  add_index "collecting_relationships", ["post_id"], :name => "index_collecting_relationships_on_post_id"
  add_index "collecting_relationships", ["user_id"], :name => "index_collecting_relationships_on_user_id"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.text     "content"
    t.integer  "user_id"
    t.string   "floor"
    t.string   "permalink"
    t.boolean  "can_be_deleted",       :default => true, :null => false
    t.integer  "total_comments_count", :default => 0,    :null => false
    t.integer  "voting_ups_count",     :default => 0,    :null => false
    t.integer  "voting_downs_count",   :default => 0,    :null => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "comments", ["created_at", "commentable_id", "commentable_type"], :name => "index_comments_on_created_at_and_commentable"
  add_index "comments", ["created_at", "user_id"], :name => "index_comments_on_created_at_and_user_id"
  add_index "comments", ["permalink"], :name => "index_comments_on_permalink", :unique => true

  create_table "following_relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "following_relationships", ["followed_id"], :name => "index_following_relationships_on_followed_id"
  add_index "following_relationships", ["follower_id", "followed_id"], :name => "index_following_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "following_relationships", ["follower_id"], :name => "index_following_relationships_on_follower_id"

  create_table "invitations", :force => true do |t|
    t.integer  "sender_id"
    t.string   "receiver_email"
    t.string   "token"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "invitations", ["created_at", "sender_id"], :name => "index_invitations_on_created_at_and_sender_id"

  create_table "messages", :force => true do |t|
    t.integer  "changed_points"
    t.integer  "current_points"
    t.text     "content"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "messages", ["created_at", "user_id"], :name => "index_messages_on_created_at_and_user_id"

  create_table "node_groups", :force => true do |t|
    t.string   "name"
    t.integer  "position",   :default => 100, :null => false
    t.string   "permalink"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "node_groups", ["permalink"], :name => "index_node_groups_on_permalink", :unique => true
  add_index "node_groups", ["position"], :name => "index_node_groups_on_position"

  create_table "nodes", :force => true do |t|
    t.string   "name"
    t.integer  "position",      :default => 100, :null => false
    t.integer  "node_group_id"
    t.string   "permalink"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "nodes", ["permalink"], :name => "index_nodes_on_permalink", :unique => true
  add_index "nodes", ["position"], :name => "index_nodes_on_position"

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.text     "content"
    t.text     "extra_info"
    t.integer  "user_id"
    t.integer  "node_id"
    t.string   "permalink"
    t.boolean  "can_be_deleted",        :default => true, :null => false
    t.integer  "views_count",           :default => 0,    :null => false
    t.integer  "direct_comments_count", :default => 0,    :null => false
    t.integer  "total_comments_count",  :default => 0,    :null => false
    t.integer  "collectors_count",      :default => 0,    :null => false
    t.integer  "voting_ups_count",      :default => 0,    :null => false
    t.integer  "voting_downs_count",    :default => 0,    :null => false
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "posts", ["permalink"], :name => "index_posts_on_permalink", :unique => true
  add_index "posts", ["updated_at", "collectors_count"], :name => "index_posts_on_updated_at_and_collectors_count"
  add_index "posts", ["updated_at", "node_id"], :name => "index_posts_on_updated_at_and_node_id"
  add_index "posts", ["updated_at", "total_comments_count"], :name => "index_posts_on_updated_at_and_total_comments_count"
  add_index "posts", ["updated_at", "user_id"], :name => "index_posts_on_updated_at_and_user_id"
  add_index "posts", ["updated_at", "voting_ups_count"], :name => "index_posts_on_updated_at_and_voting_ups_count"
  add_index "posts", ["updated_at"], :name => "index_posts_on_updated_at"

  create_table "secrets", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.text     "content"
    t.boolean  "sender_deleted",   :default => false, :null => false
    t.boolean  "receiver_deleted", :default => false, :null => false
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "secrets", ["created_at", "receiver_id"], :name => "index_secrets_on_created_at_and_receiver_id"
  add_index "secrets", ["created_at", "sender_id"], :name => "index_secrets_on_created_at_and_sender_id"

  create_table "users", :force => true do |t|
    t.string   "nickname"
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_token"
    t.string   "avatar"
    t.string   "words"
    t.boolean  "admin",                  :default => false, :null => false
    t.string   "permalink"
    t.boolean  "can_be_deleted",         :default => true,  :null => false
    t.string   "reset_token"
    t.datetime "reset_deadline"
    t.string   "confirm_token"
    t.datetime "signed_up_confirmed_at"
    t.datetime "last_signed_in_at"
    t.integer  "invitation_id"
    t.integer  "followings_count",       :default => 0,     :null => false
    t.integer  "followeds_count",        :default => 0,     :null => false
    t.integer  "great_posts_count",      :default => 0,     :null => false
    t.integer  "posts_count",            :default => 0,     :null => false
    t.integer  "collections_count",      :default => 0,     :null => false
    t.integer  "comments_count",         :default => 0,     :null => false
    t.integer  "voting_ups_count",       :default => 0,     :null => false
    t.integer  "voting_downs_count",     :default => 0,     :null => false
    t.integer  "received_secrets_count", :default => 0,     :null => false
    t.integer  "sent_secrets_count",     :default => 0,     :null => false
    t.integer  "messages_count",         :default => 0,     :null => false
    t.integer  "sent_invitations_count", :default => 0,     :null => false
    t.integer  "points_count",           :default => 30,    :null => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["confirm_token"], :name => "index_users_on_confirm_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["followeds_count"], :name => "index_users_on_followeds_count"
  add_index "users", ["great_posts_count"], :name => "index_users_on_great_posts_count"
  add_index "users", ["last_signed_in_at"], :name => "index_users_on_last_signed_in_at"
  add_index "users", ["nickname"], :name => "index_users_on_nickname", :unique => true
  add_index "users", ["permalink"], :name => "index_users_on_permalink", :unique => true
  add_index "users", ["points_count"], :name => "index_users_on_points_count"
  add_index "users", ["posts_count"], :name => "index_users_on_posts_count"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token", :unique => true
  add_index "users", ["reset_token"], :name => "index_users_on_reset_token", :unique => true
  add_index "users", ["signed_up_confirmed_at"], :name => "index_users_on_signed_up_confirmed_at"

  create_table "voting_down_relationships", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "voting_down_relationships", ["user_id"], :name => "index_voting_down_relationships_on_user_id"
  add_index "voting_down_relationships", ["votable_id", "votable_type", "user_id"], :name => "index_voting_down_relationships_on_votable_and_user_id", :unique => true
  add_index "voting_down_relationships", ["votable_id", "votable_type"], :name => "index_voting_down_relationships_on_votable"

  create_table "voting_up_relationships", :force => true do |t|
    t.integer  "votable_id"
    t.string   "votable_type"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "voting_up_relationships", ["user_id"], :name => "index_voting_up_relationships_on_user_id"
  add_index "voting_up_relationships", ["votable_id", "votable_type", "user_id"], :name => "index_voting_up_relationships_on_votable_and_user_id", :unique => true
  add_index "voting_up_relationships", ["votable_id", "votable_type"], :name => "index_voting_up_relationships_on_votable"

end
