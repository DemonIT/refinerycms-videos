module Refinery
  module Videos
    include ActiveSupport::Configurable

    config_accessor :datastore_root_path, :whitelisted_mime_types, :max_file_size, :file_prefix, :pages_per_dialog,
                    :pages_per_admin_index, :datastore_path, :skin_css_class,:video_default_width, :video_default_height,
                    :poster_mime_types, :poster_max_file_limit, :poster_datastore_path, :poster_datastore_root_path, :poster_file_prefix,
                    :view_min_width, :view_min_height

    # videos
    self.max_file_size = 104857600
    self.file_prefix = 'video'
    self.whitelisted_mime_types = %w(video/mp4)
    self.pages_per_admin_index = 10
    self.pages_per_dialog = 7
    self.video_default_width = 375
    self.video_default_height = 255
    self.datastore_path = 'system/refinery/videos'
    self.view_min_width = 300
    self.view_min_height = 200

    #poster
    self.poster_file_prefix = 'vPoster'
    self.poster_mime_types = %w(image/jpeg image/pjpeg image/png image/tiff)
    self.poster_max_file_limit = 20971520
    self.poster_datastore_path = 'system/refinery/videos/posters'


    class << self

      def datastore_root_path
        config.datastore_root_path || (Rails.root.join('public', self.datastore_path).to_s if Rails.root)
      end
      def poster_datastore_root_path
        config.poster_datastore_root_path || (Rails.root.join('public', self.poster_datastore_path).to_s if Rails.root)
      end

    end
  end
end
