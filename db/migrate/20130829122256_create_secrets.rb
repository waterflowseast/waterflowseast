class CreateSecrets < ActiveRecord::Migration
  def change
    create_table :secrets do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.text :content
      t.boolean :sender_deleted, default: false, null: false
      t.boolean :receiver_deleted, default: false, null: false

      t.timestamps
    end

    add_index :secrets, [:created_at, :sender_id]
    add_index :secrets, [:created_at, :receiver_id]
  end
end
