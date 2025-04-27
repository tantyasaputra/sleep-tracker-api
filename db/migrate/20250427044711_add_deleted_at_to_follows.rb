class AddDeletedAtToFollows < ActiveRecord::Migration[8.0]
  def change
    add_column :follows, :deleted_at, :datetime
  end
end
