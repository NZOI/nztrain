# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  include CarrierWave::MimeTypes

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "images/#{model.class.to_s.underscore}/#{mounted_as}/#{partition_dir(model.id)}/#{model.id}"
  end
  
  ## define how to partition directory (can support 1 billion users without too many immediate children in any directory)
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

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    "/images/user/avatar/" + [version_name, "default.png"].compact.join('_')
  end

  # Process files as they are uploaded:
  process :set_content_type # sets mimetype to match extension
  process :resize_to_fit => [150, 150] # suitable for forum size
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  version :small do
    process :resize_to_fill => [96, 96]
  end
  version :tiny do
    process :resize_to_fill => [32, 32] # for displaying inline in table rows
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end
