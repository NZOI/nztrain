# encoding: utf-8

class FileAttachmentUploader < CarrierWave::Uploader::Base
  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{partition_dir(model.id)}/#{model.id}"
  end
  
  ## define how to partition directory (can support 1 billion objects without too many immediate children in any directory)
  def partition_dir(modelid)
    p = modelid.to_s.rjust(6,'0')
    "#{p[0,2]}/#{p[2,2]}/#{p[4,2]}"
  end

  after :remove, :delete_empty_upstream_dirs
  def delete_empty_upstream_dirs
    path = ::File.expand_path(store_dir)
    Dir.delete(path) # fails if path not empty dir
    for i in 1..4 # iterate up the directory path
      path = ::File.expand_path("..",path)
      Dir.delete(path) # fails if path not empty dir
    end
  rescue SystemCallError
    true # nothing, the dir is not empty
  end

  # Process files as they are uploaded:
  process :set_content_type # sets mimetype to match extension

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif tif png svg pdf doc docx)
  end
end
