#! ruby -Ku

# ----------------------------------------------------------------
# モジュールの読み込み
# ----------------------------------------------------------------
this_file = File.dirname(__FILE__) + '/'
gem 'mechanize','2.7.3'
require 'mechanize'
require "date"
require this_file + '../Model/DB'

class Chart
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
    @img_agent = Mechanize.new

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
    self.getChart
  end

# ----------------------------------------------------------------
# ログイン画面
# ----------------------------------------------------------------
  def getChart
	if @currency_pair != "" then
		url = 'http://zai.diamond.jp/list/fxchart/detail?pair=' + ARGV[0] + '&time=15m'
		@img_agent.get(url)

		#1日前
		d = Date.today
		d = d-1

=begin
		#画像パス
		p @img_agent.page.uri

		#買い気配
		p @img_agent.page.at('div#index-rate/table/tr/td[2]').inner_text
		#売り気配
		p @img_agent.page.at('div#index-rate/table/tr/td[3]').inner_text
		#前日比
		p @img_agent.page.at('div#index-rate/table/tr/td[4]').inner_text
		#始値
		p @img_agent.page.at('div#index-rate/table/tr/td[5]').inner_text
		#高値
		p @img_agent.page.at('div#index-rate/table/tr/td[6]').inner_text
		#安値
		p @img_agent.page.at('div#index-rate/table/tr/td[7]').inner_text
=end
		

		rate_array = [
			@img_agent.page.at('div#index-rate/table/tr/td[5]').inner_text,#始値
			@img_agent.page.at('div#index-rate/table/tr/td[2]').inner_text,#終値
			@img_agent.page.at('div#index-rate/table/tr/td[4]').inner_text,#前日比
			@img_agent.page.at('div#index-rate/table/tr/td[7]').inner_text,#安値
			@img_agent.page.at('div#index-rate/table/tr/td[6]').inner_text,#高値
			ARGV[0],#通貨ペア
			d.strftime("%Y-%m-%d")#日付
		]			

		p rate_array
		#DB保存
		@DB.insert_rate(rate_array)

		#画像保存
		file_name = @img_agent.page.at('div.main-chart-img/img')['src']
		file = @img_agent.get(file_name)
		file.save_as(@@path_output + d.strftime("%Y_%m_%d") + "/" + ARGV[0] + "_15.png")
	end
    return true
  end
end

haa = Chart.new()
haa.start()

haa = nil
