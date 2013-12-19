class FileAttachment < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :owner, :class_name => :User

  has_many :filelinks, :dependent => :destroy

  mount_uploader :file_attachment, FileAttachmentUploader

  validates :name, :length => { :in => 0..128 }, :format => { :with => /\A[-a-zA-Z0-9\._+]*\z/, :message => "Invalid characters in filename" }
  validate do
    errors.add attr, 'extension differs from file' if File.extname(filename||"") != File.extname(file_attachment_url||"")
  end
  validates :file_attachment, :file_size => { :maximum => 4.megabytes.to_i }, :presence => true
  validate do
    if !file_attachment_was.blank? && File.extname(file_attachment.to_s) != File.extname(file_attachment_was.to_s)
      errors.add attr, 'extension cannot change'
      self.file_attachment = record.file_attachment_was
    end
  end

  def name_type=(type)
    if type == 'filename' || self.name.nil?
      self.name = ''
    end
  end

  def name_type
    self.name.nil? || self.name.empty? ? 'filename' : 'other'
  end

  def filename
    self.name.empty? ? (self.file_attachment_url||"").split('/').last : self.name
  end
end
