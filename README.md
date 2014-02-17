# Refinery CMS Video.js

Менеджер видео файлов для [Refinery CMS](http://refinerycms.com)

## Требования
Refinery CMS version 2.1.0 или выше

## Установка
Файл ``Gemfile`` должен содержать строку:

```ruby
gem 'refinerycms-videos', git: 'http://github.com/DemonIT/refinerycms-videos.git'
```

После запустите: 

    bundle install

Далее установка необходимых библиотек:

    rails generate refinery:videos
