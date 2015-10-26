# データベースにアクセスするためのライブラリを読み込む
require 'active_record'
#require 'sinatra-activerecord'

# プログラムを定期実行するためのライブラリを読み込む
require 'eventmachine'

# フィードフェッチクラスをインポート
require_relative 'Fetcher'

# プッシュ通知クラスをインポート
#require_relative 'Pusher'

# TODO: データベースの初期化
#DATABASE_URL='postgresql://localhost/myapp.db'
#ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgresql://localhost/news')
ActiveRecord::Base.establish_connection('postgresql://localhost/news')

class News < ActiveRecord::Base
end

puts News.count

puts 'record created'

# レコードが空であればDBの初期化を行う
# すべてのエントリをDBに保存する
Fetcher.parse { |element|
  # デバッグ用のログ出力処理
  puts element.elements['url'].text
}

EM.run do

  # ここでDBの初期化(すべてのエントリをDBに保存)を行うとエラーがでる

  # デバッグ用に定期実行時間を5秒に設定
  # 本番環境では60に設定すること
  EM::PeriodicTimer.new(5) do
    puts 'start fetchFeed'
    Fetcher.parse { |element|
      # 未登録のエントリのみDBに保存する
      puts element.elements['url'].text
    }
  end

end
