class AddUserIdToTreeViews < ActiveRecord::Migration[5.0]
  def change
    add_column :tree_views, :user_id, :integer
  end
end
