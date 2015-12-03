#! ruby -Ku

# ----------------------------------------------------------------
# モジュールの読み込み
# ----------------------------------------------------------------
this_file = File.dirname(__FILE__) + '/'
gem 'mechanize','2.7.3'
require 'mechanize'
require "date"
require this_file + '../Model/DB'

class Newsafter
# ----------------------------------------------------------------
# シェルでの引数
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# 出力ディレクトリ(csvファイル/住所テンプレート)
# ----------------------------------------------------------------
	@@this_file = File.dirname(__FILE__) + '/'

	if File.exist?(@@this_file + "../config/path.yaml")
		ret = YAML.load_file(@@this_file + "../config/path.yaml")
	end
	@@path_output = ret['Pre'][:img]

# ----------------------------------------------------------------
# 初期化
# ----------------------------------------------------------------
  def initialize
    #画像保存用オブジェクト
    @agent = Mechanize.new

    #Mysqlデータベース接続
    @DB = DB.new

    super
  end
  
  
# ----------------------------------------------------------------
# 一連の処理
# ----------------------------------------------------------------
  def start()
    begin
	@DB.mysql_connect("3")

      self.process()
    rescue Exception => ex
	p ex
    end
  end
  
  def process(name = nil)
    #画像取得
    self.getNews
  end

# ----------------------------------------------------------------
# ログイン画面
# ----------------------------------------------------------------
  def getNews
	url = 'http://min-fx.jp/if/market/indicators/if_indicators_w/'
	@agent.get(url)

	#本日
	d = Date.today
	compare_date = d.strftime("%d");

	table_data_count = 1
	array_text = ""


	news_date = ""
	@agent.page.search("table/tbody/tr/td").each do |elm|
		if table_data_count%7 == 1 then
			array_text = ''
			#日付
			news_date = elm.inner_text.gsub(/日.+$/,'')

			array_text = array_text + elm.inner_text
		elsif table_data_count%7 == 2 then
			#関連通貨
			array_text = array_text + "," + elm.inner_text
		elsif table_data_count%7 == 3 then
			#重要度
			#array_text = array_text + "," + elm.inner_html
			if(elm.at("img") != nil) then
				array_text = array_text + "," + elm.at("img")['alt']
			else
				array_text = array_text + ","
			end
		elsif table_data_count%7 == 4 then
			#タイトル
			array_text = array_text + "," + elm.inner_text
		elsif table_data_count%7 == 5 then
			#前回（前回修正値）
			array_text = array_text + "," + elm.inner_text
		elsif table_data_count%7 == 6 then
			#予測
			array_text = array_text + "," + elm.inner_text
		elsif table_data_count%7 == 0 then
			#結果
			array_text = array_text + "," + elm.inner_text
			#if compare_date == news_date then
				#array_text = array_text + "," + d.strftime("%Y-%m-%d")
				#DB保存
				@DB.insert_news_after(array_text)

			#end
		end
		table_data_count = table_data_count + 1
	end
  end
end

haa = Newsafter.new()
haa.start()

haa = nil
