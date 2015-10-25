News feed observer
===

NEWSフィードを監視するスクリプト

### 現象うまく動作しない
DBのマイグレーションでこける

これが一番わかりやすいかも
http://dev.classmethod.jp/server-side/ruby-on-rails/sinatra-postgresql-unicorn-on-heroku/
やりたいことに近い感じ
http://blog.notsobad.jp/post/60131290938/sinatra-heroku%E3%81%AEdb%E8%A8%AD%E5%AE%9A%E3%82%92%E3%81%84%E3%81%84%E6%84%9F%E3%81%98%E3%81%AB%E3%81%99%E3%82%8B
http://iriya-ufo.net/2014/09/07/499.html

わかりやすいかも
http://blog.notsobad.jp/post/60131290938/sinatra-heroku%E3%81%AEdb%E8%A8%AD%E5%AE%9A%E3%82%92%E3%81%84%E3%81%84%E6%84%9F%E3%81%98%E3%81%AB%E3%81%99%E3%82%8B
https://devcenter.heroku.com/articles/heroku-postgresql
http://qiita.com/myokkie/items/6f65db5d53f19d34a27c
http://qiita.com/myokkie/items/b6b68b247ec7a110a1c4

とりあえず
http://qiita.com/windhorn/items/e5eefeb4bec485ca0d39
http://apidock.com/rails/ActiveRecord/Base/establish_connection/class
http://qiita.com/xkumiyu/items/2ecee242b7e6e6c6d9a1
http://takuya-1st.hatenablog.jp/entry/20120302/1330709753
http://tsuchikazu.net/active_record_single_use/
http://easyramble.com/active-record-migration-for-sqlite3.html
http://tagamidaiki.com/ruby-active-record/

### sqlite3

dbを作成
`sqlite3 ${DB名}`

sqlファイルからsqlを実行
`.read ${SQLファイル名}`

クエリを発行
`SELECT * FROM ${テーブル名};`

http://rktsqlite.osdn.jp/sqlite/manip.html#select



### rubyのクラス定義に関する参考資料

http://qiita.com/Linda_pp/items/b7135ae1f0def6058c6c
http://shugo.net/ruby-codeconv/codeconv.html

### クラスのインポート方法
http://qiita.com/nekogeruge_987/items/2d18f388219597c75e05

### カレンダーの予定フィードを解析するための参考
http://d.hatena.ne.jp/aoi_273/20090311/1236764850
http://qiita.com/dahugani/items/72f01d04dd35f1d21b0f

### ハッシュKeyから値を取得する
http://qiita.com/kidach1/items/651b5b5580be40ad047e

### クロージャ
http://www.atmarkit.co.jp/ait/articles/1409/29/news035_3.html
http://d.hatena.ne.jp/yoshidaa/20090511/1241967137
