# データベースにアクセスするためのライブラリを読み込む
require 'sinatra/activerecord'
#require 'active_record'

# プログラムを定期実行するためのライブラリを読み込む
require 'eventmachine'

# URLにアクセスするためのライブラリを読み込む
require 'open-uri'

# HTMLをパースするためのライブラリを読み込む
require 'nokogiri'

# フィードフェッチクラスをインポート
require_relative 'fetcher'

# プッシュ通知クラスをインポート
require_relative 'pusher'

# TODO: for local
#ActiveRecord::Base.configurations = YAML.load_file('C:\Users\saito_shota\Desktop\rumix2-ruby2.1-2.10\projects\calender\database.yml')
#ActiveRecord::Base.establish_connection(:development)
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])

class Articles < ActiveRecord::Base; end

def push(url, category)
  # 新着ニュースURLがhttpスキーマであればニュースタイトルを取得する
  if url.start_with?("http://") then
    doc = Nokogiri::HTML(open(url, 'User-Agent' => 'ruby'))
    title = doc.css('head').css('title').text.gsub("...｜ニュース｜乃木坂46公式サイト", "")
    Pusher.push(url, category, title)
  end
end

# レコードが空であればDBの初期化を行う
# すべてのエントリをDBに保存する
Fetcher.parse { |element|
  url = element.elements['url'].text
  category = element.elements['category'].text
  Articles.where(:url => url).first_or_create do |e|
    puts "insert #{url}"
  end
} if Articles.count == 0

EM.run do
  # ここでDBの初期化(すべてのエントリをDBに保存)を行うとエラーがでる
  # デバッグ用に定期実行時間を5秒に設定
  # 本番環境では60に設定すること
  EM::PeriodicTimer.new(60) do
    Fetcher.parse { |element|
      puts "routine task start"
      # 未登録のエントリのみDBに保存する
      url = element.elements['url'].text
      category = element.elements['category'].text
      Articles.where(:url => url).first_or_create do |e|
        # PUSH通知する
        push(url, category)
      end
    }
  end
end
