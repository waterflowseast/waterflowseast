class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :sender_id
      t.string :receiver_email
      t.string :token

      t.timestamps
    end

    add_index :invitations, [:created_at, :sender_id]
    add_index :invitations, :receiver_email, unique: true
  end
end
