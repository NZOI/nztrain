class Filelink < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :root, polymorphic: true
  belongs_to :file_attachment

  validates :filepath, length: {in: 1..255}, format: {with: /\A[-a-zA-Z0-9._+]+(\/[-a-zA-Z0-9._+]+)*\z/, message: "Invalid characters in file path"}, uniqueness: {scope: [:root_type, :root_id]}
  validates_presence_of :file_attachment
  validates_each :filepath do |record, attr, value|
    record.errors.add attr, "extension doesn't match file" if !record.file_attachment.nil? && File.extname(value) != File.extname(record.file_attachment.filename)
  end

  before_validation do
    self.filepath = file_attachment.filename if filepath.blank?
  end

  # protected = can view if not in contest
  VISIBILITY = Enumeration.new 0 => :public, 1 => :protected, 2 => :private

  def file_attachment_url
    file_attachment.file_attachment_url
  end
end
