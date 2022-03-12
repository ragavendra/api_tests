require_relative '../lib/References'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

describe 'The Posts Service' do
	before do
		testdata = Hash.new
		@data = TestData.NewDefaultHash(testdata)

		@user = User.new(@data)

	end      

	after do
	end

	def self.test_order
		:alpha
	end

  #test cases go here
	it 'Get all posts' do

		res = @user.postsService.get_all_posts
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"
    #puts res.body
	
#=begin
		resHash = JSON.parse(res.body, symbolize_names: true)
    #puts resHash[0][:userId].
		#assert resHash.has_key?(:"id")
		assert (resHash[0][:userId].eql? 1), "Invalid post user id"
		assert (resHash[0][:id].eql? 1), "Invalid post id"
		assert (resHash[0][:title].eql? "sunt aut facere repellat provident occaecati excepturi optio reprehenderit"), "Invalid title"
		assert (resHash[0][:body].eql? "quia et suscipit\nsuscipit recusandae consequuntur expedita et cum\nreprehenderit molestiae ut ut quas totam\nnostrum rerum est autem sunt rem eveniet architecto"), "Invalid posts body"
#=end
	end

end

