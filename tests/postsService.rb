require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../services/postsService'
require_relative '../testData'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

describe 'The Posts Service' do
  before do
    data_ = TestData.new
    @data = data_.get_data
    @post = PostsService.new(@data)
  end      

  after do
  end

	def self.test_order
		:alpha
	end

  #test cases go here
	it 'Get all posts' do

    #res = @post.get_all_posts
    res = @post.GET
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash[0].has_key?(:"id")
		assert (resHash[0][:userId].eql? 1), "Invalid post user id"
		assert (resHash[0][:id].eql? 1), "Invalid post id"
		assert (resHash[0][:title].eql? "sunt aut facere repellat provident occaecati excepturi optio reprehenderit"), "Invalid title"
		assert (resHash[0][:body].eql? "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"), "Invalid posts body"
	end

	it 'Create a post' do
    title = "Title for 101"
    body = "Body for 101"
    userId = 124
    req = @post.create_post title, body, userId
    res = @post.POST req
		assert res.code == 201, "Invalid response code #{res.inspect}, should be 201-Created"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:"id")
		assert (resHash[:userId].eql? userId), "Invalid post user id"
		assert (resHash[:title].eql? title), "Invalid title"
		assert (resHash[:body].eql? body), "Invalid posts body"
	end

	it 'Update a post with put' do
    title = "Title for 102"
    body = "Body for 102"
    userId = 1
    postId = 1
    req = @post.update_post title, body, userId, postId
    res = @post.PUT req
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-Success"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:"id")
		assert (resHash[:userId].eql? userId), "Invalid post user id"
		assert (resHash[:title].eql? title), "Invalid title"
		assert (resHash[:body].eql? body), "Invalid posts body"
	end

	it 'Update a post\'s body field with patch' do
    body = "Body for 102"
    userId = 1
    postId = 1
    req = @post.update_post_fields "", body, userId, postId
    res = @post.PATCH req
    assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-Success"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:"id")
		assert (resHash[:userId].eql? userId), "Invalid post user id"
		assert (resHash[:body].eql? body), "Invalid posts body"
	end
  
	it 'Delete a post' do
    body = "Body for 102"
    postId = 1
    @post.delete postId
    res = @post.DELETE
    assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-Success"
	end

	it 'Get posts by user' do
    userId = 1
    @post.get_post_user userId
    res = @post.GET
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash[0].has_key?(:"id")
		assert (resHash[0][:userId].eql? 1), "Invalid post user id"

    resHash.each do | post | 
      assert (post[:userId].eql? 1), "Invalid post user id"
    end
  end

	it 'Get comments for a post' do
    postId = 1
    @post.get_comments_post postId
    res = @post.GET
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		#assert (post[:userId].eql? 1), "Invalid post user id"

    resHash.each do | post | 
      # assert (post[:userId].eql? 1), "Invalid post user id"
      assert post.has_key?(:"id")
      assert post.has_key?(:"postId")
      assert post.has_key?(:"name")
      assert post.has_key?(:"email")
      assert post.has_key?(:"body")
    end

	end


end
