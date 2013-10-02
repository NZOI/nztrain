class FileAttachment < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :owner, :class_name => :User

  has_many :group_file_attachments
  has_many :problem_file_attachments

  mount_uploader :file_attachment, FileAttachmentUploader

  validates :name, :length => { :in => 0..128 }, :format => { :with => /\A[-a-zA-Z0-9\._+]*\z/, :message => "Invalid characters in filename" }
  validates :file_attachment, :file_size => { :maximum => 4.megabytes.to_i }, :presence => true

  def name_type=(type)
    if type == 'filename' || self.name.nil?
      self.name = ''
    end
  end

  def name_type
    self.name.nil? || self.name.empty? ? 'filename' : 'other'
  end

  def filename
    self.name.empty? ? self.file_attachment_url.split('/').last : self.name
  end
end
