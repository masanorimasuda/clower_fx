#! c:/ruby1.8/bin/ruby -Ku

# 日本語変換・処理ライブラリ(コマンドプロンプトの文字コードがsjis)
require "kconv"
require 'rubygems'

require "yaml"
require "pp"
require 'jcode'


# Mysql用ライブラリ
require "mysql"

# ==============================================================================
# DB class(MySQL)
# ==============================================================================
class DbSetting
	def initialize
		#mysql接続フラグ
		@mysql_connect_flg = 0
		this_file = File.dirname(__FILE__) + '/'

		if File.exist?(this_file + "../config/db.yaml")
			ret = YAML.load_file(this_file + "../config/db.yaml")
			#pp ret
		end
		
		@dbname = ret['Pre'][:dbname]
		@host = ret['Pre'][:host]
		@user = ret['Pre'][:user]
		@password = ret['Pre'][:password]
		
		#マッチングエラーの数
		@matching_error_count = 0
		#Homesのデータ入力数
		@matching_count = 0

		super
	end

	# class名
	@@file_name = "DbSetting"
	
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
				#接続開始
				@my.real_connect(@host,@user,@password)

				# -----------------------------------#
				#			ID,Passを取得
				# -----------------------------------#
				@my.query("use " + "3nosuke")
				@my.query('set names utf8;')

				return "MYSQLデータベース接続成功<br />"
			rescue => e
				@mysql_connect_flg = 0
				return "MYSQLデータベース接続失敗<br />"
			end
		end
	end

	# ----------------------------------------------------------------
	# セッティング情報取得
	# ----------------------------------------------------------------
	def returnIdPass(site_name) 
		res = @my.query("select * from password where SiteName = '" + site_name + "'")
		res.each do |col|
			col1 = col[1]
			col2 = col[2]
			col3 = col[3]
			return col1,col2,col3
		end
		
	end
	# ----------------------------------------------------------------
	# データ挿入(住所)
	# ----------------------------------------------------------------
	def insert_mysql(h,ken_cd,site_name)
		
		#データベース入力(MYSQLに)
		begin
			#my.query("insert into test1 values ('0','test',150);")
			@table_name = "cd" + ken_cd
			i = 1
			temp_sql_define = ""
			sql_define_key = ""
			sql_define_value = ""

			h.each{|key, value|
				if ( i == 1 ) then
					temp_sql_define = key + " = '" + value + "'"
					sql_define_key = key
					sql_define_value = "'" + value + "'"
				else
					temp_sql_define = temp_sql_define + ", " +  key + " = '" + value + "'"
					sql_define_key = sql_define_key + "," + key
					sql_define_value = sql_define_value + ",'" + value + "'"
				end
				i = i + 1
			}

			puts "insert into " + @table_name + " (" + sql_define_key + ")" + " values (" + sql_define_value + ");"

			#temp_sql_define = temp_sql_define +";"
			puts inputed_no = default_id_search(h,ken_cd)

			if ( inputed_no != 0 ) then
				sql = "UPDATE " + @table_name +  " SET " + temp_sql_define + " WHERE ID = '" + inputed_no + "';"
				#sql = "replace into " + @table_name + " values ('" + rowdata + "');"
				@matching_count = @matching_count + 1
			else
				if (site_name == "Homes") then
					sql = "insert into " + @table_name + " (" + sql_define_key + ")" + " values (" + sql_define_value + ");"
					@matching_count = @matching_count + 1
				else
					sql = "insert into " + @table_name + " (" + sql_define_key + ")" + " values (" + sql_define_value + ");"
					@matching_count = @matching_count + 1
=begin
					puts "データベースにデータが見つかりませんでした。(Homesと住所のミスマッチ)" + sql_define_value
					@matching_error_count = @matching_error_count + 1
=end
				end
			end
			puts sql + "<br />"
			#SQL文発行実行
			@my.query(sql)
			return @matching_count,@matching_error_count
		rescue => e
			p e
			puts "MYSQL書き込み失敗<br />"
			return @matching_count,@matching_error_count
			return false
		end
	end

	# ----------------------------------------------------------------
	# データ挿入(駅)
	# ----------------------------------------------------------------
	def insert_mysql_eki(h,site_name)
		#データベース入力(MYSQLに)
		begin
			#my.query("insert into test1 values ('0','test',150);")
			@table_name = "Ensen"
			i = 1
			temp_sql_define = ""
			sql_define_key = ""
			sql_define_value = ""
			h.each{|key, value|
				if ( i == 1 ) then
					temp_sql_define = key + " = '" + value + "'"
					sql_define_key = key
					sql_define_value = "'" + value + "'"
				else
					temp_sql_define = temp_sql_define + ", " +  key + " = '" + value + "'"
					sql_define_key = sql_define_key + "," + key
					sql_define_value = sql_define_value + ",'" + value + "'"
				end
				i = i + 1
			}
			#temp_sql_define = temp_sql_define +";"
			#puts temp_sql_define
	
			#配列を文字列へ","で連結
			##rowdata = array_set.join("','")
			

			puts inputed_no = default_id_search(h,"Ensen")

			#puts @matching_count
			#puts @matching_error_count
			if ( inputed_no != 0 ) then
				sql = "UPDATE " + @table_name +  " SET " + temp_sql_define + " WHERE ID = '" + inputed_no + "';"
				@matching_count = @matching_count + 1
				#sql = "replace into " + @table_name + " values ('" + rowdata + "');"
			else
				if (site_name == "Homes") then
					sql = "insert into " + @table_name + " (" + sql_define_key + ")" + " values (" + sql_define_value + ");"
					#sql = "insert into " + @table_name + " values ('" + rowdata + "');"
					@matching_count = @matching_count + 1
				else
					sql = "insert into " + @table_name + " (" + sql_define_key + ")" + " values (" + sql_define_value + ");"
					#sql = "insert into " + @table_name + " values ('" + rowdata + "');"
					@matching_count = @matching_count + 1
=begin
					puts "データベースにデータが見つかりませんでした。(Homesと住所のミスマッチ)" + sql_define_value
					@matching_error_count = @matching_error_count + 1
=end
				end
			end
			puts sql + "<br />"
			

			#SQL文発行実行
			@my.query(sql)
			return @matching_count,@matching_error_count
		rescue => e
			puts "MYSQL書き込み失敗<br />"
			return @matching_count,@matching_error_count
		end
	end
	
# ----------------------------------------------------------------
# データ取得関数
# ----------------------------------------------------------------
	# ----------------------------------------------------------------
	# データ検索(実際にデータが入っているかflagを取得)
	# ----------------------------------------------------------------
	def default_id_search(h,ken_cd)
		if ken_cd == "Ensen" then
			@table_name = ken_cd
		else
			@table_name = "cd" + ken_cd
		end
		inputed_id = 0
		temp_sql_define_search = ""
		i = 1

		#ハッシュのDateキーの値を削除
		h.delete('Date')

		h.each{|key, value|
			#ホームズのフィールドで比較する
			if key =~ /rosen/ || key =~ /eki/ || key =~ /shiku/ || key =~ /chouson/ || key =~ /chou/ then
				key_sql = key.sub(/^[^_]+_/,"Homes_").to_s
			else
				key_sql = key
			end
			if key =~ /chou/ && value == "" then
				value = "なし"
			end
			#コードは比較を行わない
			if key =~ /cd/ then
				
			else
				if ( i == 1 ) then
					temp_sql_define_search = key_sql + " = '" + value + "'"
				else
					temp_sql_define_search = temp_sql_define_search + " AND " +  key_sql + " = '" + value + "'"
				end
				i = i + 1
			end
			
		}

		puts temp_sql_define_search
		puts "select ID from " + @table_name + " where " + temp_sql_define_search + ";"

		begin
			res = @my.query("select ID from " + @table_name + " where " + temp_sql_define_search + ";")
			res.each do |row,collum|
				inputed_id = row
			end	

			return inputed_id
		rescue => e
			puts "flag取得失敗<br />"
			return inputed_id
		end
	end
	
	# ----------------------------------------------------------------
	# データ検索(inputed日付け取得)
	# ----------------------------------------------------------------
	def get_inserted_date(bknID)
		
		begin
			inputed_date = ""
			sql2 = "select inserted_at from " + @table_name + " where bknID = '" + bknID + "'"
			res2 = @my.query(sql2)
			res2.each do |row,collum|
				inputed_date = row.to_s
			end
			#puts sql2
		rescue => e
			puts "select文実行エラー<br />"
		end
		return inputed_date
	end
	
	# ----------------------------------------------------------------
	# データ検索(入居旬コード)(hkwtsNyukyShn_tbl)
	#	1 	上旬
	# 	2 	中旬
	# 	3 	下旬
	# ----------------------------------------------------------------	
	def get_hkwtsNyukyShn_no(text)
		#初期値
		hkwtsNyukyShn_no = 0
		if text != "-" && text != "－" && text != "" then
			begin
				res = @my.query("select id from hkwtsNyukyShn_tbl where name = '" + text + "'")
				res.each do |row,collum|
				  hkwtsNyukyShn_no = row
				end
				if hkwtsNyukyShn_no == 0 && text != "-" && text != "－" && text != "" then
					puts "データ検索(入居旬コード)ID取得失敗<br />"
				end
			rescue => e
				puts "データ検索(入居旬コード)ID取得失敗(MYSQLより)<br />"
			end
		end
		return hkwtsNyukyShn_no
	end			

end
