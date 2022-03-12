require 'active_record'

#module MySQL
	def connect_db

		ActiveRecord::Base.establish_connection(
			:adapter => "mysql2",
			:host => ENV['HOST'],
			:database => "soa_db",
			:username => "root",
			:password => ""
		)
	end

	def update_db connection, sql
		connection.connection.execute(sql);
	end

	def fetch_db connection, sql
		@result = @connection.connection.execute(sql);
	
		# use below to fetch data in rows and cols
		#@result.each(:as => :hash) do |row| 
		#	puts row["member_id"] 
		#end
	end
#end

