# URLにアクセスするためのライブラリを読み込む
require 'open-uri'

# XMLをパースするためのライブラリを読み込む
require 'rexml/document'

class Fetcher

  def self.parse

    # RSSフィードを取得する
    url = 'http://img.nogizaka46.com/calendar/allnews.xml'
    xml = open(url)

    # 取得したフィード(XML)の読み込み
    doc = REXML::Document.new(open(xml))

    # 解析する
    doc.elements.each('newslist/array_item') do |element|
      yield(element)
    end

  end
end
