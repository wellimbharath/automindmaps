class CreateTreeViews < ActiveRecord::Migration[5.0]
  def change
    create_table :tree_views do |t|
      t.string :link

      t.timestamps
    end
  end
end
