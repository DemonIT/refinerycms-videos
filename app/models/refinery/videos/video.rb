module Refinery
  module Videos
    class Video < Refinery::Core::BaseModel
      self.table_name = 'refinery_videos'
      require 'acts_as_indexed'

      attr_accessible :id, :title, :poster_img, :file_name, :file_mime_type, :file_size, :file_url_name

      #delegate :size, :mime_type, :url, :name, :to => :file

      validates :title, :file_name, :file_mime_type, :file_size, :file_url_name, presence: true
      #acts_as_indexed :fields => [:title]

      def download_url
        "/#{Refinery::Videos.datastore_path}/#{self.file_url_name}"
      end

      def get_title
        self.title || self.file_name
      end

      def get_file_ext
        self.file_name.split('.').last
      rescue
        ''
      end

      # Returns a titleized version of the filename
      # my_file.pdf returns My File
      #def title
      #  CGI::unescape(file_name.to_s).gsub(/\.\w+$/, '').titleize
      #end

      class << self

        def with_query(search_text = '')
          where(["lower(title) like lower(?)", "%#{search_text}%"])
        end

      end

    end
  end
end
