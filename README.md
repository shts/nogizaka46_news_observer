Nogizaka46 News observer
===

アプリのダッシュボード
https://dashboard.heroku.com/apps/nogizaka46-news-observer/resources

### postgresql連携

下記の構成でDB読み込み可能となった

Rakefile
```
require 'yaml'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'

ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)
```
database.yml
```
development:
  adapter: postgresql
  database: XXXXXXXXXX
  pool: 5
  host: XXXXXXXXXXXXXXX.com
  username: XXXXXXXXXXXXXXXXXXXX
  password: XXXXXXXXXXXXXXXXXXXX
```
main.rb
＃`require 'sinatra/activerecord'`を利用するとクエリ発行時にログ出力される
＃`YAML.load_file`はフルパスを指定しないとファイルが見つからないエラーが発生する
＃`Rakefile`は相対パスの指定だがrakeコマンド実行時にエラーは発生しなかった

```

require 'active_record'
#require 'sinatra/activerecord'

ActiveRecord::Base.configurations = YAML.load_file('${projectのフルパス}\database.yml')
ActiveRecord::Base.establish_connection(:development)

# この指定方法だとパスをgit上に管理することになる
#ActiveRecord::Base.establish_connection(
#  adapter:  "postgresql",
#  host:     "XXXXXXXXXXXXXXX.com",
#  username: "XXXXXXXXXXXXXXXXXXXX",
#  password: "XXXXXXXXXXXXXXXXXXXX",
#  database: "XXXXXXXXXXXXXXXXXXXX",
#)
class Articles < ActiveRecord::Base; end

puts Articles.count

```

### 実行コマンド

`bundle exec rake db:create_migration NAME=${databasename}`
`bundle exec rake db:migration`

### heroku-postgresqlの設定

`heroku addons:add heroku-postgresql`

でaddon追加して、


`heroku config`

で追加されたURLを確認。


`heroku pg:promote HEROKU_POSTGRESQL_(COLOR)_URL`

でDATABASE_URLを設定しとく。


`heroku run rake db:migrate`

でテーブル作成。


### ローカルでの確認方法

heroku-postgresql-Addonを利用するためには下記のよう指定する必要がある。これはアドオンと環境変数の設定によりURLを指定するだけでよしなにやってくれるというもの。
```
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
```
＃結局デプロイ時には下記のようにした
```
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
```

ローカルでこのやり方ができないのでデプロイ時には処理を変更し、動作未確認のままデプロイするしかないかも。

ローカルではdatabase.ymlを利用してheroku-postgresql(アドオンではない)に接続して確認する。またはsqlite3など`'schema://localhost/mydb'`で接続可能な別のDBを利用する。
ローカルにpostgresqlの環境を作成したところでデプロイ時にソースコードの修正が必要になりそう。
`'postgres://localhost/mydb'` この指定方法で接続可能なのか？

先にheroku-postgresqlを作成するとアプリも作成される。このアプリにデプロイ可能なのでDB -> Appの順に作成可能

デプロイ後に `heroku config` を実行すると下記のように自動的にアドオンが追加されている状態になる
あとは `heroku run rake db:migrate` を実行する
＃ローカルから実行済みの場合、すでにテーブルが作成されているので意味ないかも

```
$ heroku config
=== heroku-postgres-26153c5a Config Vars
DATABASE_URL:               postgres://wwnnycwffgexjl:r41Kn7vQsCg4dZNrbJw6ElIsr0@ec2-54-225-197-30.compute-1.amazonaws.com:5432/da04bmtor9ntb6
HEROKU_POSTGRESQL_CYAN_URL: postgres://wwnnycwffgexjl:r41Kn7vQsCg4dZNrbJw6ElIsr0@ec2-54-225-197-30.compute-1.amazonaws.com:5432/da04bmtor9ntb6
LANG:                       en_US.UTF-8
RACK_ENV:                   production
Updating Heroku CLI... done.
```

デプロイ後にはwebプロセスが起動しているので、workerプロセスに切り替える。
が下記のよう実行するworkerプロセスとエラー
http://qiita.com/zucay/items/5dc8dbd348557b5c23c2
-> 実行名間違い

```
[C:calender]
$ heroku ps
=== web (Free): `bundle exec rackup config.ru -p $PORT`
web.1: crashed 2015/10/27 14:03:08 (~ 5m ago)

[C:calender]
$ heroku ps:scale web=0
Scaling dynos... done, now running web at 0:Free.
[C:calender]
$ heroku ps:scale worker=1
Scaling dynos... failed
 !    Couldn't find that formation.
```

Procfileに記述した名前を指定する必要がある
Procfile に記述したコマンドが `observe: bundle exec ruby main.rb` の場合 `heroku ps:scale observe=1` とする

```
[C:calender]
$ heroku ps:scale worker=1
Scaling dynos... failed
 !    Couldn't find that formation.
[C:calender]
$ heroku ps:scale observer=1
Scaling dynos... failed
 !    Couldn't find that formation.
[C:calender]
$ heroku ps:scale observe=1
Scaling dynos... done, now running observe at 1:Free.
```


### まとめ

**ローカル動作確認**

ローカルのPostgreSQLの環境構築がややこしいので [HerokuPostgresのHP](https://www.heroku.com/postgres) からDBを作成してローカルからリモート操作して動作を確認する。
https://postgres.heroku.com/databases

* 下記をGemfileに記述すること

```
gem 'rake'
gem 'pg'
```

* HerokuPostgresにDBを作成する
* 作成したDBのプロパティを`database.yml`に記述しActiveRecordから読み込む。
このとき`database.yml`の読み込み処理はフルパスで記述し、`.gitignore`ファイルに追加すること
* Rakefileを作成し`bundle exec rake db:create_migration NAME=${databasename}`を実行.${databasename}は必ず小文字を指定すること！
* 上記手順によって生成されたファイルを修正し`bundle exec rake db:migrate`を実行

**HerokuへDeploy**

* 実行コマンド`[appname]: [command]`を記述したProcfileを作成する

ex) `observe: bundle exec ruby main.rb`

* .rbファイルまたはRakefileに記述されたActiveRecordの処理をHeroku用に修正する
before
```
ActiveRecord::Base.configurations = YAML.load_file('${appdir}/database.yml')
ActiveRecord::Base.establish_connection(:development)
```
after
```
ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
```

* Herokuアプリとローカルのリポジトリをリンクさせる。HerokuHPよりDBアドオンのみのアプリケーションがあるので、そのアプリケーションの「Deploy」ページに記述されたgitコマンドを入力する

* 下記手順にてDeploy

`git add .`

`git commit -m "Deploy heroku"`

`git push heroku master`

* 初回はWebプロセスが起動しているので停止し、Procfileに記述したWorkerプロセスに切り替える

`heroku ps:scale web=0`

`heroku ps:scale ${appname}=1`

${appname}はProcfileに記述したアプリ名

* ログを見て動作に問題ないか確認する

`heroku logs`

* たまに下記のようなログが出力され止まってしまう。その場合 `heroku restart` コマンドを実行する
```
2014-10-31T01:00:04.752860+00:00 heroku[bot.1]: Starting process with command `bundle exec ruboty`
2014-10-31T01:00:05.675499+00:00 heroku[bot.1]: State changed from starting to up
2014-10-31T01:00:04.954595+00:00 heroku[bot.1]: Stopping all processes with SIGTERM
2014-10-31T01:00:10.282889+00:00 heroku[bot.1]: Process exited with status 143
```

http://qiita.com/tbpgr/items/5f3969fba3b6f8a8e1c0

* `heroku pg:reset DATABASE` でデータベースを初期化できる

```
$ heroku pg:reset DATABASE

 !    WARNING: Destructive Action
 !    This command will affect the app: heroku-postgres-16ca77a1
 !    To proceed, type "heroku-postgres-16ca77a1" or re-run this command with --confirm heroku-postgres-16ca77a1

> heroku-postgres-16ca77a1
Resetting DATABASE_URL... done
```

* データベース初期化後は再度マイグレーションを行う必要がある

ローカルでRakefileをdatabase.ymlからロードするように修正し、 `bundle exec rake db:migrate` を実行し、クラウドのDBをマイグレーションする。マイグレーション完了後ファイルを元に戻しておく。
＃ `heroku run rake db:migrate` でもよいのでは？

```
#TODO: for local
ActiveRecord::Base.configurations = YAML.load_file('C:\Users\saito_shota\Desktop\rumix2-ruby2.1-2.10\projects\crawler\database.yml')
ActiveRecord::Base.establish_connection(:development)
#ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
```


### 参考資料

http://blog.notsobad.jp/post/60070706766/sinatra-activerecord-postgresql%E3%81%A7%E3%83%87%E3%83%BC%E3%82%BF%E3%83%99%E3%83%BC%E3%82%B9%E6%93%8D%E4%BD%9C
