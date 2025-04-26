class CreateUsers < ActiveRecord::Migration[8.0]
  def up
    create_table :users do |t|
      t.string :email, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :users, :email, unique: true
  end

  def down
    drop_table :users
  end
end
