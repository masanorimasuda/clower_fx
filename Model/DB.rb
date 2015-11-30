#! ruby -Ku


require "yaml"


# Mysql用ライブラリ
require "mysql"


# ==============================================================================# DB class(MySQL)
# ==============================================================================
class DB
	def initialize

		#mysql接続フラグ(接続成功: 1,未接続: 0)
		@mysql_connect_flg = 0
# ----------------------------------------------------------------
# MYSQLデータベース情報取得
# ----------------------------------------------------------------
		this_file = File.dirname(__FILE__) + '/'
		if File.exist?(this_file + "../config/db.yaml")
			ret = YAML.load_file(this_file + "../config/db.yaml")
			#pp ret
		end

		@dbname = ret['Pre'][:dbname]
		@host = ret['Pre'][:host]
		@user = ret['Pre'][:user]
		@password = ret['Pre'][:password]

		super
	end

	# class名
	@@file_name = "DB"
	
# ----------------------------------------------------------------
# MYSQLデータベース接続
# ----------------------------------------------------------------
	def mysql_connect(option_no)
		if @mysql_connect_flg == 0 then
			#初期化
			@my = Mysql.init()
			
			#文字コードの設定
			@my.options(Mysql::SET_CHARSET_NAME, "utf8")
			begin
# ----------------------------------------------------------------
# 接続開始
# ----------------------------------------------------------------
				@my.real_connect(@host,@user,@password)
				#テーブル選択
				@my.query("use " + @dbname)
				#文字コードの確認
				#p @my.character_set_name()
				# queryの文字コード
				@my.query("set character set utf8")
				@my.query('set names utf8;')
				@mysql_connect_flg = 1
				return "MYSQLデータベース接続成功<br />"
			rescue => e
				p e
				@mysql_connect_flg = 0
				return "MYSQLデータベース接続失敗<br />"
			end
		end
	end

# ----------------------------------------------------------------
# データ挿入処理(レート)
# ----------------------------------------------------------------
	def insert_rate(array)
		#データベース入力(MYSQLに)
		begin
			#沿線取得の時テーブルを設定
			@table_name = ARGV[0]

			# SQL文出力
			sql = "INSERT INTO " + @table_name + " (start,end,compare,lowest,highest,currency,date) VALUES ("
			sql = sql + array[0] + "," + array[1] + "," + array[2] + "," + array[3] + "," + array[4] + ",'" + array[5] + "','" + array[6] + "');"
			
			#SQL文発行実行
			@my.query(sql)

		rescue => e
			p e
		end
	end

	#news予定の保存
	def insert_news(insert_text)
		#データベース入力(MYSQLに)
		begin
			#沿線取得の時テーブルを設定
			@table_name = ARGV[0]

			array = insert_text.split(",")

			#p array
			# SQL文出力
			sql = "INSERT INTO news_before (textdate,currency,attention_rate,title,before_value,forecast,result,date) VALUES ('"
			sql = sql + array[0] + "','" + array[1] + "','" + array[2] + "','" + array[3] + "','','','','" + array[4] + "');"
			
			#SQL文発行実行
			@my.query(sql)

		rescue => e
			p e
		end

	end


	#news結果の保存
	def insert_news_after(insert_text)
		#データベース入力(MYSQLに)
		begin
			#沿線取得の時テーブルを設定
			@table_name = ARGV[0]

			array = insert_text.split(",")

			#p array
			# SQL文出力
			sql = "UPDATE news_before SET before_value = '"+ array[4] + "',forecast = '" + array[5] + "',result = '" + array[6] + "' WHERE (textdate = '" + array[0] + "' AND currency = '" + array[1] + "' AND attention_rate = '" + array[2] + "' AND title = '" + array[3] + "');"
			
			#SQL文発行実行
			@my.query(sql)

		rescue => e
			p e
		end

	end


end

