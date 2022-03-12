
require 'singleton'
require 'thread'
require 'date'

class Unique

	include Singleton

	def initialize
		#use the lock to ensure thread safety. minitest allows for concurrent test execution
		#so i want this singleton to work in a concurrent context
		@lock = Mutex.new
		#we use a thread safe member to keep track of the last ID given out
		#initialize it to be 1 second before now
		@lastId = (DateTime.now.strftime('%Q').to_i()-1).to_s()
	end

	def Id(testdata)
		#because i want to use this singleton in tests that run with minitest concurrent
		#i have to ensure thread safety here. if multiple threads all want unique info, i can't give them 
		#the same ID based on unix time. this critical section will introduce a bottleneck on concurrent tests
		#such that we can start no more than 1 test per millisecond. i can live with that. 
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
			#take our unique ID string and turn it into a unique binary ID
			intId = id.to_i(10)
			binaryIdStr = intId.to_s(2)
			testdata.store(:test_binaryId,binaryIdStr) 
			#while i am here, i want the date time recoreded for debugging tests
			testdata.store(:test_executiontime,now.strftime())
		}
	end


end

