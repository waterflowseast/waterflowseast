class CreateVotingDownRelationships < ActiveRecord::Migration
  def change
    create_table :voting_down_relationships do |t|
      t.integer :votable_id
      t.string :votable_type
      t.integer :user_id

      t.timestamps
    end

    add_index :voting_down_relationships, [:votable_id, :votable_type], name: "index_voting_down_relationships_on_votable"
    add_index :voting_down_relationships, :user_id
    add_index :voting_down_relationships, [:votable_id, :votable_type, :user_id], unique: true, name: "index_voting_down_relationships_on_votable_and_user_id"
  end
end
