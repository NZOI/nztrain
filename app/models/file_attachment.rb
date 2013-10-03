class FileAttachment < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :owner, :class_name => :User

  has_many :group_file_attachments
  has_many :problem_file_attachments

  mount_uploader :file_attachment, FileAttachmentUploader

  validates :name, :length => { :in => 0..128 }, :format => { :with => /\A[-a-zA-Z0-9\._+]*\z/, :message => "Invalid characters in filename" }
  validates_each :filename do |record, attr, value|
    record.errors.add attr, 'extension differs from file' if File.extname(value) != File.extname(record.file_attachment_url)
  end
  validates :file_attachment, :file_size => { :maximum => 4.megabytes.to_i }, :presence => true
  validates_each :file_attachment do |record, attr, value|
    if !record.file_attachment_was.blank? && File.extname(value.to_s) != File.extname(record.file_attachment_was.to_s)
      record.errors.add attr, 'extension cannot change'
      record.file_attachment = record.file_attachment_was
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
    self.name.empty? ? self.file_attachment_url.split('/').last : self.name
  end
end
