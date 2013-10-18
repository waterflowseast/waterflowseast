# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "avatars/#{model.permalink}"
  end

  def filename
    "#{model.permalink}_#{Time.zone.now.strftime('%Y%m%d_%H%M%S')}" + File.extname(super) if original_filename.present?
  end

  version :big do
    process resize_to_fill: [128, 128]
  end

  version :medium, from_version: :big do
    process resize_to_fill: [64, 64]
  end

  version :small, from_version: :big do
    process resize_to_fill: [32, 32]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end
