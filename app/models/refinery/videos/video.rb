module Refinery
  module Videos
    class Video < Refinery::Core::BaseModel
      self.table_name = 'refinery_videos'
      require 'acts_as_indexed'


      attr_accessible :id, :title, :poster_img, :file_name, :file_mime_type, :file_size, :file_url_name
      attr_accessor :file, :poster_file, :old_poster_img
      #delegate :size, :mime_type, :url_name, :name, :to => :file

      validates :title, presence: true
      validates :file, presence: true, on: :create
      #acts_as_indexed :fields => [:title]

      validate :upload_video_file, :on => :create
      validate :upload_poster_file #, :on => [:create, :update]


      def upload_video_file
        unless file.nil?
          # все допустимые типы файлов для данного раздела
          file_content_types = Refinery::Videos.whitelisted_mime_types.to_a
          max_file_size = Refinery::Videos.max_file_size.to_i
          file_content_type = file_content_types.find_all{|cntp| cntp.to_s == file.content_type.chomp.to_s}
          if file_content_type.any?
            #raise file.class.to_s
            if file.size.to_i > max_file_size
              errors.add(:file, ::I18n.t('file_big_size', scope: 'activerecord.errors.models.refinery/videos/video') )
            else
              file_prefix = Refinery::Videos.file_prefix
              this_data_file_id = object_id
              file_type = file.original_filename.split('.').last
              self.file_url_name = "#{file_prefix}_#{current_time_text}_#{this_data_file_id}.#{file_type}"
              self.file_name = file.original_filename.to_s
              self.file_mime_type = file.content_type.chomp.to_s
              self.file_size = file.size.to_i
            end
          else
            errors.add(:file, ::I18n.t('file_type_uncorrect', scope: 'activerecord.errors.models.refinery/videos/video', norm_file_mime_types:  file_content_types.map{|ftype| "*.#{ftype.split('/').last}"}.uniq.join(', ') ) )
          end
        end
      end

      after_create do
        file_data = file.read
        directory_path = Refinery::Videos.datastore_root_path
        FileUtils.mkdir_p(directory_path) unless File.exists?(directory_path)
        file_url_path = "#{directory_path}/#{self.file_url_name}"
        File.open(file_url_path, 'wb'){|f| f.write(file_data)}
      end

      after_save do
        unless poster_file.nil?
          poster_file_data = poster_file.read
          poster_directory_path = Refinery::Videos.poster_datastore_root_path
          FileUtils.mkdir_p(poster_directory_path) unless File.exists?(poster_directory_path)
          unless self.old_poster_img.blank?
            old_poster_path = "#{poster_directory_path}/#{self.old_poster_img}"
            File.delete(old_poster_path) if File.exist?(old_poster_path)
          end
          new_poster_path = "#{poster_directory_path}/#{self.poster_img}"
          File.open(new_poster_path, 'wb'){|f| f.write(poster_file_data)}
        end
      end

      def upload_poster_file
        unless poster_file.nil?
          #file_data = poster_file.read
          # все допустимые типы файлов для данного раздела
          file_content_types = Refinery::Videos.poster_mime_types.to_a
          max_file_size = Refinery::Videos.poster_max_file_limit.to_i
          file_content_type = file_content_types.find_all{|cntp| cntp.to_s == poster_file.content_type.chomp.to_s}
          if file_content_type.any?
            #raise file.class.to_s
            if poster_file.size.to_i > max_file_size
              errors.add(:poster_img, ::I18n.t('file_big_size', scope: 'activerecord.errors.models.refinery/videos/video') )
            else
              file_prefix = Refinery::Videos.poster_file_prefix
              this_data_file_id = object_id
              file_type = poster_file.original_filename.split('.').last
              self.poster_img = "#{file_prefix}_#{current_time_text}_#{this_data_file_id}.#{file_type}"
            end
          else
            errors.add(:poster_img, ::I18n.t('file_type_uncorrect', scope: 'activerecord.errors.models.refinery/videos/video', norm_file_mime_types:  file_content_types.map{|ftype| "*.#{ftype.split('/').last}"}.uniq.join(', ') ) )
          end
        end
      end

      def download_url
        "/#{Refinery::Videos.datastore_path}/#{self.file_url_name}"
      end

      def poster_url
        "/#{Refinery::Videos.poster_datastore_path}/#{self.poster_img}"
      end

      def get_title
        self.title || self.file_name
      end

      def get_file_ext
        self.file_name.split('.').last
      rescue
        ''
      end



      def current_time_text
        current_time = Time.now
        "#{current_time.year}#{current_time.month}#{current_time.day}#{current_time.hour}#{current_time.min}"
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
