class TreeView < ApplicationRecord
   belongs_to :user
   has_attached_file :file
   validates_attachment_content_type :file, :content_type =>  ["application/pdf","application/vnd.ms-excel",
             "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
             "application/msword",
             "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
             "text/plain"]
end
