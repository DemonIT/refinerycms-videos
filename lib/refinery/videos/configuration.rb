module Refinery
  module Videos
    include ActiveSupport::Configurable

    config_accessor :datastore_root_path, :whitelisted_mime_types, :max_file_size, :file_prefix, :pages_per_dialog,
                    :pages_per_admin_index, :datastore_path, :skin_css_class,:video_default_width, :video_default_height



    # my config

    self.max_file_size = 104857600
    self.file_prefix = 'video'
    self.whitelisted_mime_types = %w(video/mp4 application/ogg video/webm video/ogg video/ogv)
    self.pages_per_admin_index = 10
    self.pages_per_dialog = 7
    self.video_default_width = 375
    self.video_default_height = 255
    self.datastore_path = 'system/refinery/videos'
    #end my-config





    class << self


      # my config
      def datastore_root_path
        config.datastore_root_path || (Rails.root.join('public', self.datastore_path).to_s if Rails.root)
      end


      # end my config
      #def s3_backend
      #  config.s3_backend.nil? ? Refinery::Core.s3_backend : config.s3_backend
      #end
      #
      #def s3_bucket_name
      #  config.s3_bucket_name.nil? ? Refinery::Core.s3_bucket_name : config.s3_bucket_name
      #end
      #
      #def s3_access_key_id
      #  config.s3_access_key_id.nil? ? Refinery::Core.s3_access_key_id : config.s3_access_key_id
      #end
      #
      #def s3_secret_access_key
      #  config.s3_secret_access_key.nil? ? Refinery::Core.s3_secret_access_key : config.s3_secret_access_key
      #end
    end
  end
end
