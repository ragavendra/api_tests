#require_relative 'unique'

class TestData

	def self.NewDefaultHash(data)
		data = Hash.new
		#default data with unique requirements
		#unique = Unique.instance
		#unique.Id(data)

		#test suite defaults
		data.store(:test_poll_attempts, 60)
		data.store(:test_poll_interval_seconds, 1)
    data.store(:host, ENV['HOST'] || 'jsonplaceholder.typicode.com')
		data.store(:protocol,ENV['HTTP_PROTOCOL'] || 'https')

    #posts data
		data.store(:posts_id, 10)
		data.store(:posts_userId, 1)
    data.store(:posts_title, "Title for 101")
    data.store(:posts_body, "Body for 101")
    data
	end
end
