require_relative 'unique'

class TestData

	def self.NewDefaultHash(user_data)
		data = Hash.new
		#default data with unique requirements
		unique = Unique.instance
		unique.Id(data)

		#test suite defaults
		data.store(:test_poll_attempts,60)
		data.store(:test_poll_interval_seconds,1)
		#data.store(:host,'cards-m2')
		#data.store(:host,'dockervm')
    data.store(:host, ENV['HOST'] || 'jsonplaceholder.typicode.com')
		data.store(:port, ENV['HTTP_PORT'] || '443')
		data.store(:protocol,ENV['HTTP_PROTOCOL'] || 'https')

    #posts data
		data.store(:posts_title, "")
		data.store(:posts_body, "")
		data.store(:posts_id, "")
		data.store(:posts_userId, "")

	
		#data.store(:path,' ')
		MergeUserOverrides(data,user_data)
		VariableSubstitution(data)
		return data
	end

	def self.MergeUserOverrides(default_data,user_data)
		#todo - merge the user_data over top of the default data so that user can override defaults
		default_data.merge!(user_data)
	end

	def self.VariableSubstitution(data)
		data.each_value {|value| if (value!=nil && value.instance_of?(String) && value.include?('${test_id}')) then value.gsub!('${test_id}',data[:test_id]) end }	
	end

end
