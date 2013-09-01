class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :changed_points
      t.integer :current_points
      t.text :content
      t.integer :user_id

      t.timestamps
    end

    add_index :messages, [:created_at, :user_id]
  end
end
