refinerycms-videos
==================
# Refinery CMS Video.js

Менеджер видео файлов для [Refinery CMS](http://refinerycms.com)

## Требования
Refinery CMS version 2.1.0 или выше

## Установка
Фййл ``Gemfile`` должен содержать строку:

```ruby
gem 'refinerycms-videos', git: 'http://github.com/DemonIT/refinerycms-videos.git'
```

Now, run: 

    bundle install

Next, to install the video extension run:

    rails generate refinery:videos
