# Parseライブラリの読み込み
require 'parse-ruby-client'

# Parseライブラリの初期化
Parse.init :application_id => ENV['PARSE_APP_ID'],
           :api_key        => ENV['PARSE_API_KEY']

class Pusher

  def self.push(url, category, title)
    data = { :action=> "android.shts.jp.nogifeed.UPDATE_NEWS",
             :_category => category,
             :_title => title,
             :_url => url }
    push = Parse::Push.new(data)
    push.where = { :deviceType => "android" }
    p push.save
  end

end
