module Refinery
  module Videos
    class Engine < Rails::Engine
      extend Refinery::Engine
      isolate_namespace Refinery::Videos

      engine_name :refinery_videos

      engine_name :refinery_videos
      config.before_initialize do
        unless File.exists?('config/initializers/refinery/videos.rb')
          puts "\e[33mClass `#{engine_name}` can not be created.
                Please run `rails g refinery:#{self.parent_name.split('::').last.downcase}` to generate the necessary files.\e[0m"
          exit 1
        end if defined?(Rails::Server) ||  defined?(Rails::Console)
      end

      initializer "register refinerycms_videos plugin" do
        Refinery::Plugin.register do |plugin|
          plugin.name = "videos"
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.videos_admin_videos_path }
          plugin.pathname = root
          plugin.activity = {
            :class_name => :'refinery/videos/video'
          }
          
        end
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Videos)
      end
    end
  end
end
