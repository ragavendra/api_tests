require 'singleton'
require 'thread'
require 'date'

class Unique

	include Singleton

	def initialize
		@lock = Mutex.new
		@lastId = (DateTime.now.strftime('%Q').to_i()-1).to_s()
	end

	def Id(testdata)
		@lock.synchronize {
			now = DateTime.now
			id = now.strftime('%Q')
			while (id <=> @lastId) == 0 do
				sleep(0.001)
				now = DateTime.now
				id = now.strftime('%Q')
			end
			@lastId = id.dup
			testdata.store(:test_id,id)
			intId = id.to_i(10)
			binaryIdStr = intId.to_s(2)
			testdata.store(:test_binaryId,binaryIdStr) 
			testdata.store(:test_executiontime,now.strftime())
		}
	end


end

