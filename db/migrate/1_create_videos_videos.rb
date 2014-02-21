class CreateVideosVideos < ActiveRecord::Migration

  def up
    create_table :refinery_videos do |t|
      t.text :file_name
      t.text :file_mime_type
      t.text :file_url_name
      t.integer :file_size
      t.string :title
      t.text :description
      t.integer :position
      t.text :poster_img

      t.timestamps
    end
    add_index :refinery_videos, :id

  end

  def down
    if defined?(::Refinery::UserPlugin)
      ::Refinery::UserPlugin.destroy_all({:name => "refinerycms-videos"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/videos/videos"})
    end

    drop_table :refinery_videos

  end

end
