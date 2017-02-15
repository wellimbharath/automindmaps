class AddAttachmentFileToTreeViews < ActiveRecord::Migration
  def self.up
    change_table :tree_views do |t|
      t.attachment :file
    end
  end

  def self.down
    remove_attachment :tree_views, :file
  end
end
