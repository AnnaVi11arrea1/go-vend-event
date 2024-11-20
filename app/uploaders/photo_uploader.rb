class PhotoUploader < CarrierWave::Uploader::Base
  storage :file # Or :fog for cloud storage like AWS S3
end
