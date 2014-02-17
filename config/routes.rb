Refinery::Core::Engine.routes.draw do

  # default =)
  ## Frontend routes
  #namespace :videos do
  #  resources :videos, :path => '', :only => [:index, :show]
  #end
  #
  ## Admin routes
  #namespace :videos, :path => '' do
  #  namespace :admin, :path => Refinery::Core.backend_route do
  #    resources :videos, :except => :show do
  #      collection do
  #        post :update_positions
  #      end
  #    end
  #  end
  #end


  # my

  # Admin routes
  namespace :videos, :path => '' do
    namespace :admin, :path => Refinery::Core.backend_route do
      get 'videos/insert', to: 'videos#insert'
      get 'videos/video_to_html(/:video_id)', to: 'videos#video_to_html', as: 'video_to_html'
      post 'videos/video_to_html', to: 'videos#video_to_html', as: 'video_to_html'
      resources :videos do
        get :download
      end
    end
  end


end
