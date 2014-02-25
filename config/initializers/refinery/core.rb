Refinery::Core.configure do |config|

  # Add extra tags to the wymeditor whitelist e.g. = {'tag' => {'attributes' => {'1' => 'href'}}} or just {'tag' => {}}
  config.wymeditor_whitelist_tags.merge!( {
      'video'  =>  {
          'attributes'  =>  {
              '1'  =>  'width' ,
              '2'  =>  'height' ,
              '3'  =>  'poster',
              '4'  =>  'controls',
              '5'  =>  'preload'
          }
      },
      'source'  =>  {
          'attributes'  =>  {
              '1'  =>  'src' ,
              '2'  =>  'type'
          }
      }
  }
  )

  # Register extra javascript for backend
  config.register_javascript 'refinery/videos/wymeditor_add_video'
  config.register_javascript 'refinery/videos/form_valid'
  config.register_javascript 'refinery-videos'

  #Register extra stylesheet for backend (optional options)
  config.register_stylesheet 'refinery/videos/videos'
  config.register_stylesheet 'refinery-videos'
end