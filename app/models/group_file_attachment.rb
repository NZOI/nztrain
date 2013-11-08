class GroupFileAttachment < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :group
  belongs_to :file_attachment

  validates :filepath, :length => { :in => 1..255 }, :format => { :with => /\A[-a-zA-Z0-9\._+]+(\/[-a-zA-Z0-9\._+]+)*\z/, :message => "Invalid characters in file path" }, :uniqueness => { scope: :group_id }
  validates_presence_of :file_attachment
  validates_each :filepath do |record, attr, value|
    record.errors.add attr, "extension doesn't match file" if !record.file_attachment.nil? && File.extname(value) != File.extname(record.file_attachment.filename)
  end

  before_validation do
    self.filepath = self.file_attachment.filename if self.filepath.blank?
  end

  def file_attachment_url
    self.file_attachment.file_attachment_url
  end
end
