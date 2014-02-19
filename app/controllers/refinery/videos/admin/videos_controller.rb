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

        def edit
          @video_id = params[:id].to_i
          @video_base = Video.find(@video_id)
          directory_path = Refinery::Videos.datastore_root_path
          file_url_path = "#{directory_path}/#{@video_base.file_url_name}"
          exception_file_not_found file_url_path unless File.exist? file_url_path
        end

        def create
          begin
            Video.transaction do
              @video = Video.new(title: params[:video][:title].to_s)
              @video.file = params[:video][:file]
              @video.poster_file = params[:video][:poster_file]
              if @video.save
                flash[:notice] = t 'successfully_finish', scope: 'refinery.videos.admin.videos.upload', file_title: @video.get_title
                redirect_to_index
              else
                flash[:error] = @message_error.to_s
                redirect_to refinery.new_videos_admin_video_path and return
              end
            end
          rescue => exp
            begin
              file_url_path = "#{ Refinery::Videos.datastore_root_path}/#{@video.file_url_name}"
              File.delete file_url_path if File.exists? file_url_path unless file_url_path.blank?
              unless params[:video][:poster_file].nil?
                old_poster_path = "#{Refinery::Videos.poster_datastore_root_path}/#{@video.old_poster_img}"
                File.delete old_poster_path if File.exists? old_poster_path unless old_poster_path.blank?
              end
            rescue
              puts "Fails System Fail: Video Files don't delete"
            end
            #ignored
            raise exp
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
            @video = Video.find(video_id)
            @video.title = params[:video][:title].to_s
            if params[:video][:poster_file]
              @video.old_poster_img = @video.poster_img
              @video.poster_file = params[:video][:poster_file]
            end
            if @video.save
              flash[:notice] = t 'successfully_finish', scope: 'refinery.videos.admin.videos.update', file_title: @video.get_title
              redirect_to_index
            else
              render :edit
            end
          end
        end


        def destroy
          video_id = params[:id].to_i
          video = Video.find(video_id)
          Video.transaction do
            video_title = video.get_title
            #Video.destroy
            if video.destroy
              file_url_path = "#{Refinery::Videos.datastore_root_path}/#{video.file_url_name}"
              File.delete file_url_path if File.exist? file_url_path unless video.file_url_name.blank?
              unless video.poster_img.blank?
                poster_file_url_path = "#{Refinery::Videos.poster_datastore_root_path}/#{video.poster_img}"
                File.delete poster_file_url_path if File.exist? poster_file_url_path
              end
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
          raise EOFError, "RefineryVideoFile not found: #{file_name}"
        end


        # notes
        #create_or_update_successful надо попробовать
      end
    end
  end
end
