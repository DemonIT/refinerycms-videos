module Refinery
  class VideosGenerator < Rails::Generators::Base
    desc("This generator creates Refinery::Videos files")
    source_root File.expand_path('../videos/templates', __FILE__)

    def generate_video_migrations
      rake "refinery_videos:install:migrations"
    end

    def rake_db
      rake "db:migrate"
    end

    def generate_videos_initializer
      template "config/initializers/refinery/videos.rb.erb", File.join(destination_root, "config", "initializers", "refinery", "videos.rb")
    end

    def generate_videojs_loader
      template "assets/javascripts/video.js", File.join(destination_root, "app", "assets", "javascripts", "video.js")
    end
    def generate_video_css
      template "assets/stylesheets/video-js.css", File.join(destination_root, "app", "assets", "stylesheets", "video-js.css")
    end
    def generate_video_public
      template "public/video-js.swf", File.join(destination_root, "public", "video-js.swf")
      directory "public/font", File.join(destination_root, "public", "font")
    end

    def append_load_seed_data
      create_file 'db/seeds.rb' unless File.exists?(File.join(destination_root, 'db', 'seeds.rb'))
      append_file 'db/seeds.rb', :verbose => true do
        <<-EOH

# Added by Refinery CMS Videos extension
Refinery::Videos::Engine.load_seed
        EOH
      end
    end

  end
end
