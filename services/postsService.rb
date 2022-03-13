require_relative 'ServiceBase'

class PostsService < ServiceBase

	def initialize(data)
		super(data)
		@route = "/posts"
	end

	def get_all_posts 
		GET()
	end

	def get_post 
		@route = @route + "/#{@data[:post_id]}"
		GET()
	end

  def create_post title = "", body = "", userId = 1
    req = { title: title, body: body, userId: userId }

    POST req
  end

  def update_post title = "", body = "", userId = 1, postId = 1

    @route = @route + "/" + postId.to_s

    req = { id: postId, title: title, body: body, userId: userId }

    PUT req
  end

  #lets say title and body are editable
  def update_post_fields title = "", body = "", userId = 1, postId = 1

    @route = @route + "/" + postId.to_s

    if title.eql? ""
      req = { body: body } 
    elsif body.eql? ""
      req = { title: title } 
    end

    PATCH req
  end

  def delete postId = 1
    @route = @route + "/" + postId.to_s
    DELETE() 
  end

	def get_post_user userId = 1
		@route = @route + "?userId=#{userId}"
		GET()
	end

	def get_comments_post postId = 1
		@route = @route + "/#{postId}/comments"
		GET()
	end


end
