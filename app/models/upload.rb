class Upload < ActiveRecord::Base
  attr_accessible :upload
  has_attached_file :upload
  
  default_scope :order => 'position'

  include Rails.application.routes.url_helpers

  def to_jq_upload
    {
      "name" => read_attribute(:upload_file_name),
      "size" => read_attribute(:upload_file_size),
      "url" => upload.url(:original),
      "delete_url" => upload_path(self),
      "delete_type" => "DELETE" 
    }
  end

end
