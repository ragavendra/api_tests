require_relative 'ServiceBase'

class PostsService < ServiceBase

	def initialize(data)
		super(data)
		@route = "/posts/"
	end

	def get_all_posts 
		PollingGET()
	end


	def get_post 
		@route = @route +  "#{@data[:post_id]}"
		PollingGET()
	end

	def create_post title = "", body = "", userId = 1
		req = { 
			title: title,
			body: body, 
			userId: userId 
		}

		res =  PollingPOST(req)
		
		if res.code == 200
			response_hash = JSON.parse(res.body, symbolize_names: true) if res.body
			@data.store(:post_id, response_hash[:id])
		end
		
		res
	end

end
