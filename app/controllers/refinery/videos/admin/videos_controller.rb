module Refinery
  module Videos
    module Admin
      class VideosController < ::Refinery::AdminController

        require 'will_paginate'
        require 'will_paginate/active_record'  # or data_mapper/sequel
        require 'will_paginate/array'
        include ActionView::Helpers::NumberHelper

        rescue_from Exception, :with => :exception_work
        crudify :'refinery/videos/video',
                :title_attribute => 'title',
                :xhr_paging => true,
                :order => 'created_at DESC'

        def download
          video_id = params[:video_id].to_i
          video_base = Video.find(video_id)
          directory_path = Refinery::Videos.datastore_root_path
          file_url_path = "#{directory_path}/#{video_base.file_url_name}"
          if File.exist? file_url_path
            send_file(file_url_path, :filename => video_base.file_name, :type => video_base.file_mime_type, :stream=>false, :disposition=>"attachment")
          else
            exception_file_not_found file_url_path
          end
        end

        def new
          @video = Video.new
          @file_content_types = Refinery::Videos.whitelisted_mime_types
          @file_size_limit = Refinery::Videos.max_file_size.to_i
        end

        def edit
          @video_id = params[:id].to_i
          @video_base = Video.find(@video_id)
          directory_path = Refinery::Videos.datastore_root_path
          file_url_path = "#{directory_path}/#{@video_base.file_url_name}"
          exception_file_not_found file_url_path unless File.exist? file_url_path
        end

        def create
          @message_error = ''
          if request.post?
            file_url_path = ''
            begin
              directory_path = Refinery::Videos.datastore_root_path
              file_prefix = Refinery::Videos.file_prefix
              param_upload_file = params[:video][:file]
              if param_upload_file
                file_data = param_upload_file.read
                # все допустимые типы файлов для данного раздела
                file_content_types = Refinery::Videos.whitelisted_mime_types
                file_content_type = file_content_types.find_all{|cntp| cntp.to_s == param_upload_file.content_type.chomp.to_s}
                if file_content_type.any?
                  # тип загружаемого файла
                  file_content_type = file_content_type.first
                  if file_data.length.to_i > Refinery::Videos.max_file_size.to_i
                    @message_error = t 'file_big_size', :scope => 'refinery.videos.admin.videos.upload', :big_file_size => number_to_human_size(file_data.length), :norm_file_size => number_to_human_size(Refinery::Videos.max_file_size)
                  else
                    # все проверки пройдены - пишем файла
                    file_type = param_upload_file.original_filename.split('.').last
                    Video.transaction do
                      # дополнительные приготовления и задание оригинального имени по назанчению файла
                      @original_file_name = param_upload_file.original_filename.to_s
                      #this_data_file_id = Video.get_sequence_id.to_i if this_data_file_id.to_i == 0
                      new_data_file = Video.new(:file_name => @original_file_name,:title => params[:video][:title].to_s, :file_mime_type => file_content_type, :file_size => file_data.length.to_i)
                      this_data_file_id = new_data_file.object_id
                      file_url_name = "#{file_prefix}_#{current_time_text}_#{this_data_file_id}.#{file_type}"
                      file_url_path = "#{directory_path}/#{file_url_name}"
                      new_data_file.file_url_name = file_url_name
                      if new_data_file.save
                        FileUtils.mkdir_p(directory_path) unless File.exists?(directory_path)
                        File.open(file_url_path, 'wb'){|f| f.write(file_data)}

                        flash[:notice] = t 'successfully_finish', scope: 'refinery.videos.admin.videos.upload', file_title: new_data_file.get_title
                      else
                        @message_error = t 'bd_errors', scope: 'refinery.videos.admin.videos.errors'
                      end
                    end
                  end
                else
                  @message_error = t('file_type_uncorrect', scope: 'refinery.videos.admin.videos.errors')
                  #@message_error += " || #{param_upload_file.content_type.chomp.to_s}" if Rails.env.to_s == 'development'
                end
              else
                @message_error = t('file_is_null', scope: 'refinery.videos.admin.videos.errors')
              end
            rescue => exp
              File.delete file_url_path if File.exists? file_url_path unless file_url_path.blank?
              #ignored
              raise exp
            end
          end
          @dialog_successful = from_dialog?
          unless @message_error.blank?
            flash[:error] = @message_error.to_s
            self.new # important for dialogs
            render :action => :new
          else
            redirect_to_index
          end
        end


        def insert
          searching? ? search_all_videos : find_all_videos
          paginate_videos
          if request.xhr?
            render '_insert_list_videos', :layout => false
          else
            @default_width = Refinery::Videos.video_default_width
            @default_height = Refinery::Videos.video_default_height
          end
        end

        def video_to_html
          if request.xhr?
            @tab_name = params[:tab_name].to_s
            if @tab_name == 'insert_preview'
              @video = Video.find(params[:video_id].to_i)
            elsif @tab_name == 'append_to_wym'
              @video = Video.find(params[:video_id].to_i)
              @video_width = params[:width].to_i
              @video_height = params[:height].to_i
            else
              @tab_name = ''
            end
          else
            render :nothing => true, :layout => false, :status => 404
          end
        end

        def update
          video_id = params[:id].to_i
          Video.transaction do
            video_title = params[:video][:title].to_s
            @video = Video.update(video_id, {title: video_title})
            if @video.valid?
              flash[:notice] = t 'successfully_finish', scope: 'refinery.videos.admin.videos.update', file_title: @video.get_title
              redirect_to_index
            else
              render :action => :edit
            end
          end
        end


        def destroy
          video_id = params[:id].to_i
          video = Video.find(video_id)
          directory_path = Refinery::Videos.datastore_root_path
          Video.transaction do
            video_title = video.get_title
            #Video.destroy
            if video.destroy
              file_url_path = "#{directory_path}/#{video.file_url_name}"
              File.delete file_url_path if File.exist? file_url_path unless video.file_url_name.blank?
              flash[:notice] = t 'successfully_finish', scope: 'refinery.videos.admin.videos.destroy', file_title: video_title
              if from_dialog?
                @dialog_successful = true
                render :nothing => true, :layout => true
              else
                redirect_to refinery.videos_admin_videos_path and return
              end
            else
              @message_error = t 'bd_errors', scope: 'refinery.videos.admin.videos.destroy'
            end
          end
          unless @message_error.nil?
            flash[:error] = @message_error
            redirect_to_index
          end
        end

        private

        def paginate_per_page
          from_dialog? ? Refinery::Videos.pages_per_dialog : Refinery::Videos.pages_per_admin_index
        end

        #def paginate_all_videos
        #  @videos = Video.all
        #  paginate_videos
        #end
        def paginate_videos
          #@videos *= 50
          @videos = @videos.paginate(:page => params[:page], :per_page => paginate_per_page)
        end

        def current_time_text
          current_time = Time.now
          #"#{current_time.year}-#{current_time.month}-#{current_time.day}_#{current_time.hour}-#{current_time.min}"
          "#{current_time.year}#{current_time.month}#{current_time.day}#{current_time.hour}#{current_time.min}"
        end

        def exception_work(exp)
          puts "Error: #{exp.class} - '#{exp.message}'"
          if exp.class == ActiveRecord::RecordNotFound
            exception_redirect_to_index 'search_bd_of_null'
          elsif exp.class == EOFError && exp.message.start_with?('RefineryVideoFile not found')
            exception_redirect_to_index 'search_file_of_null'
          elsif exp.class == ActionView::MissingTemplate
            render file: 'public/404.html', :status => 404
          else
            raise exp
          end
        end

        def exception_redirect_to_index(translate_error_text = t('translate_error_text', :scope => 'refinery.videos.admin.videos.errors'))
          flash[:error] = t translate_error_text.to_s, :scope => 'refinery.videos.admin.videos.errors'
          redirect_to_index
        end

        def redirect_to_index
          if from_dialog?
            @dialog_successful = true
            render :nothing => true, :layout => true and return
          else
            redirect_to refinery.videos_admin_videos_path and return
          end
        end

        def exception_file_not_found(file_name)
          raise EOFError, "RefineryVideoFile not found: #{file_url_path}"
        end


        # notes
        #create_or_update_successful надо попробовать
      end
    end
  end
end
