require_relative 'ServiceBase'

class PostsService < ServiceBase

	def initialize(data)
		super(data)
		#@route = "/posts"
	end

	def get_all_posts 
		@route = "/posts"
	end

	def get_post 
		@route + "/posts/#{@data[:post_id]}"
	end

  def create_post title = "", body = "", userId = 1
		@route = "/posts"

    { title: title, body: body, userId: userId }
  end

  def update_post title = "", body = "", userId = 1, postId = 1
    @route = "/posts/" + postId.to_s

    { id: postId, title: title, body: body, userId: userId }
  end

  #lets say title and body are editable
  def update_post_fields title = "", body = "", userId = 1, postId = 1
    @route = "/posts/" + postId.to_s

    if title.eql? ""
      { body: body } 
    elsif body.eql? ""
      { title: title } 
    end
  end

  def delete postId = 1
    @route = "/posts/" + postId.to_s
  end

	def get_post_user userId = 1
		@route = "/posts?userId=#{userId}"
	end

	def get_comments_post postId = 1
		@route = "/posts/#{postId}/comments"
	end

end
