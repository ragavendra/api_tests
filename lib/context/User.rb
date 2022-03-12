class User
  attr_accessor :postsService 

  def initialize(data)
    @data = data
    @postsService = PostsService.new(@data)
   end
end
