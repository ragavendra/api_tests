require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../services/postsService'
require_relative '../testData'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

describe 'The Posts Service' do
	before do
		testdata = Hash.new
		@data = TestData.NewDefaultHash(testdata)
	end      

	after do
	end

	def self.test_order
		:alpha
	end

  #test cases go here
	it 'Get all posts' do

		@user = PostsService.new(@data)
    res = @user.get_all_posts
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash[0].has_key?(:"id")
		assert (resHash[0][:userId].eql? 1), "Invalid post user id"
		assert (resHash[0][:id].eql? 1), "Invalid post id"
		assert (resHash[0][:title].eql? "sunt aut facere repellat provident occaecati excepturi optio reprehenderit"), "Invalid title"
		assert (resHash[0][:body].eql? "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"), "Invalid posts body"
	end

	it 'Create a post' do

		@user = PostsService.new(@data)
    title = "Title for 101"
    body = "Body for 101"
    userId = 124
    res = @user.create_post title, body, userId
		assert res.code == 201, "Invalid response code #{res.inspect}, should be 201-Created"
	
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:"id")
		assert (resHash[:userId].eql? userId), "Invalid post user id"
		assert (resHash[:title].eql? title), "Invalid title"
		assert (resHash[:body].eql? body), "Invalid posts body"
	end
end
