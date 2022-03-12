require_relative '../lib/ApiLib'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'
require_relative '../lib/contextObjects/mysql_helper'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

email = ''
describe 'The Card Service ' do
	before do
		testdata = Hash.new
		#testdata.store(:user_pwd,'1q2w3e4r1')
		#get our data filled in with defaults-our supplied data overrides the defaults 
		@opts = ApiDefaultTestData.NewDefaultHash(testdata)

		@apiUser = ApiUser.new(@opts)
		#puts @opts.inspect

		#signup, activate, login and credit application
		res = @apiUser.memberService.signup
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
#=begin
		resHash = JSON.parse(res.body, symbolize_names: true)
		@opts[:confirmation_token] =  resHash[:confirmation_token]

		res = @apiUser.memberService.activate
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
#=end
		res = @apiUser.memberService.login
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
	
		#puts "Login token #{res.inspect}"

		res = @apiUser.memberService.create_profile
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		res = @apiUser.memberService.edit_profile
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		#puts "Profile response - #{res.inspect}"
	
#=begin updating db manually. Replace with api once ready by dev 
		@connection = connect_db
		@sql = "UPDATE members set profile_completed_at = '#{Time.new.strftime("%Y-%m-%d %I:%M:%S")}' where email_address = '#{@opts[:user_email]}'"
		@result = update_db @connection, @sql 

		@sql = "UPDATE members set fraud_decision = 'accept' where email_address = '#{@opts[:user_email]}'"
		@result = update_db @connection, @sql 
		
		@sql = "UPDATE members set kyc_decision = 'approved' where email_address = '#{@opts[:user_email]}'"
		@result = update_db @connection, @sql

#=end
	
	end      

	after do
	end

	def self.test_order
		:alpha
	end

	#M1-S1
	#M6 - PT# 110096068 - AC1 and AC4 - 01
	it 'A logged in member can create a card' do
		#add query to check card count
		@sql = "select count from card_designs where id = '#{@opts[:card_id]}'"
		
		#You may have to run the SQL 'select * from soa_db.card_designs;'to note the count
		@result = fetch_db @connection, @sql
		#@result.first[0].eql?99999975
		count = @result.first[0]
		@result = 0

		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"
		
		@result = fetch_db @connection, @sql
		
		#check if the card count is decremented by 1
		assert (@result.first[0].eql? (count - 1)) , "Card count is not decremented by 1"
		
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:"id")
		@opts[:card_application_id] = resHash[:id]
		#assert (resHash[:activated_at].eql? '') , "Result hash: #{resHash.inspect}"
		assert (resHash[:activated_at].eql? nil) , "Invalid activated at"
		assert (resHash[:address].eql? @opts[:account_address]) , "Invalid address"
		assert (resHash[:birth_date].eql? @opts[:account_birth_date]) , "Invalid birth date"
		assert (resHash[:card_design_id].eql? @opts[:card_design_id]) , "Invalid card design id"
		assert (resHash[:card_id].eql? @opts[:card_id]) , "Invalid card id"
		#assert (resHash[:card_order_id].eql? @opts[:card_order_id]) , "Invalid card order id"
		assert (resHash[:city].eql? @opts[:account_city]) , "Invalid city"
		assert (resHash[:first_name].eql? @opts[:account_first_name]) , "Invalid first name"
		assert (resHash[:last_name].eql? @opts[:account_last_name]) , "Invalid last name"
		#assert (resHash[:member_id].eql? @opts[:account_member_id]) , "Invalid member id"
		#assert (resHash[:person_id].eql? @opts[:account_person_id]) , "Invalid person id"
		assert (resHash[:phone_number].eql? @opts[:account_phone_number]) , "Invalid phone number"
		assert (resHash[:postal_code].eql? @opts[:account_postal_code].to_s) , "Invalid postal code"
		assert (resHash[:province].eql? @opts[:account_province]) , "Invalid province"
		assert (resHash[:suite].eql? @opts[:account_suite]) , "Invalid suite"
		assert (resHash[:links].eql? [{:method=>"POST", :rel=>"activate_card", :uri=>"/cards/#{@opts[:card_id]}/activate"}]) , "Invalid links"

	end

#=begin You may have to run the SQL 'update soa_db.card_designs set count = 0;' and try this spec
	#to connect to db 'mysql -h cards-m3 -u root -p'
	#M3-S10
	it 'A logged in member cannot add card if there is no more cards stock in the system' do
		#fetch card count
		@sql = "select count from card_designs where id = '#{@opts[:card_id]}'"
		
		#You may have to run the SQL 'select * from soa_db.card_designs;'to note the count
		@result = fetch_db @connection, @sql
		count = @result.first[0]
	
		#update count to 0
		@sql = "UPDATE card_designs set count = 0 where id = '#{@opts[:card_id]}'"
		@result = update_db @connection, @sql 
		
		#create card application
		res = @apiUser.cardService.create
		
		#restore count to before
		@sql = "UPDATE card_designs set count = #{count} where id = '#{@opts[:card_id]}'"
		@result = update_db @connection, @sql 
		
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_create_card_controller_cards_stock_too_low") , "Invalid error key #{resHash[:errors]}"
		assert (resHash[:errors][0][:msg].eql? "CreateCardController::CardsStockTooLow") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
		
	end

=begin when member kyc is ready, enbale this spec
	#M3-S10
	it 'A logged in member cannot add card if the member profile is not completed' do
		
		@sql = "UPDATE members set profile_completed_at = #{nil} where email_address = '#{@opts[:user_email]}'"
		@result = update_db @connection, @sql 

		#@sql = "UPDATE members set fraud_decision = 'accept' where email_address = '#{@opts[:user_email]}'"
		#@result = update_db @connection, @sql 
		
		#@sql = "UPDATE members set kyc_decision = 'approved' where email_address = '#{@opts[:user_email]}'"
		#@result = update_db @connection, @sql
		
		#create card application
		res = @apiUser.cardService.create
		
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request #{res}"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_create_card_controller_cards_stock_too_low") , "Invalid error key #{resHash[:errors]}"
		assert (resHash[:errors][0][:msg].eql? "CreateCardController::CardsStockTooLow") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
		
	end
=end
	#M3-S10
	it 'A logged in member cannot add card if the fraud decision is not - accept' do
		
		@sql = "UPDATE members set fraud_decision = '' where email_address = '#{@opts[:user_email]}'"
		@result = update_db @connection, @sql 
		
		#@sql = "UPDATE members set kyc_decision = 'approved' where email_address = '#{@opts[:user_email]}'"
		#@result = update_db @connection, @sql
		
		#create card application
		res = @apiUser.cardService.create
		
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request #{res}"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_services_member_fraud_check_failed") , "Invalid error key #{resHash[:errors]}"
		assert (resHash[:errors][0][:msg].eql? "Services::Member::FraudCheckFailed") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
		
	end

	#M3-S10
	it 'A logged in member cannot add card if the kyc decision is not - approved' do
		
		@sql = "UPDATE members set kyc_decision = '' where email_address = '#{@opts[:user_email]}'"
		@result = update_db @connection, @sql
		
		#create card application
		res = @apiUser.cardService.create
	
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request #{res}"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_name_error") , "Invalid error key #{resHash[:errors]}"
		assert (resHash[:errors][0][:msg].eql? "Services::Member::KycFailed") , "Invalid error msg PT# 110119716 #{resHash[:errors]}"
		#assert (resHash[:errors][0][:msg].eql? "uninitialized constant Services::Member::KycFailed") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property #{resHash[:errors]}"
		
	end

	#M4 - S1 - #43
	it 'A logged in member can activate card after creating card' do
		#puts "Email id - '#{@opts[:user_email]}'"
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		#below response when not in fis network
		#{"errors"=>[{"key"=>"fis_no_method_error", "msg"=>"undefined method `attributes' for nil:NilClass", "property"=>"fis"}], "success"=>false}

		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.activate_card

		# below response for fis REMOTE_CALL: "" and network disconnect
		#{"errors"=>[{"key"=>"fis_net_read_timeout", "msg"=>"Net::ReadTimeout", "property"=>"fis"}], "success"=>false}	

		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		assert resHash.has_key?(:activated_at), "Response does not have activated_at"
		assert resHash.has_key?(:created_at), "Response does not have created_at"
		assert resHash.has_key?(:updated_at), "Response does not have updated_at"
		assert resHash.has_key?(:person_id), "Response does not have person id"
		assert (resHash[:card_design_id].eql? @opts[:card_design_id]) , "Invalid card design id"
		assert (resHash[:id].eql? @opts[:card_id]) , "Invalid card id"
		assert (resHash[:member_id].eql? @opts[:user_id]) , "Invalid member id"
		assert (resHash[:person_id].eql? @opts[:card_person_id]) , "Invalid person id"
		assert (resHash[:pin].eql? @opts[:card_pin]) , "Invalid pin"
		assert (resHash[:proxy_key].eql? @opts[:card_proxy_key]) , "Invalid proxy key"
	end

	#M4 - S1 - #43
	it 'A logged in member can get card info after activating card' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		res = @apiUser.cardService.get
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		assert resHash.has_key?(:activated_at), "Response does not have activated_at"
		assert resHash.has_key?(:created_at), "Response does not have created_at"
		assert resHash.has_key?(:updated_at), "Response does not have updated_at"
		assert resHash.has_key?(:person_id), "Response does not have person id"
		assert (resHash[:card_design_id].eql? @opts[:card_design_id]) , "Invalid card design id"
		assert (resHash[:id].eql? @opts[:card_id]) , "Invalid card id"
		assert (resHash[:member_id].eql? @opts[:user_id]) , "Invalid member id"
		assert (resHash[:person_id].eql? @opts[:card_person_id]) , "Invalid person id"
		assert (resHash[:links].eql? [{:method=>"POST", :rel=>"activate_card", :uri=>"/cards/#{@opts[:card_id]}/activate"}]) , "Invalid link #{resHash}"
	end
	
	#M4 - S1 - #43
	it 'A logged in member can index cards info after activating card' do
		res = @apiUser.cardService.index_cards
		assert (res.code.eql? 200), "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:links].eql? [{:method=>"POST", :rel=>"create_card", :uri=>"/cards"}]) , "Invalid links" #PT-108808094
	
		#create card application
		res = @apiUser.cardService.create
		assert (res.code.eql? 200), "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:links].eql? [{:method=>"POST", :rel=>"activate_card", :uri=>"/cards/#{@opts[:card_id]}/activate"}]) , "Invalid link #{resHash}" #PT-108808094
		
		res = @apiUser.cardService.activate_card
		assert (res.code.eql? 200), "Invalid response code #{res}, should be 200-OK"
		
		res = @apiUser.cardService.index_cards
		assert (res.code.eql? 200), "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		assert resHash[:body][0].has_key?(:activated_at), "Response does not have activated_at"
		assert resHash[:body][0].has_key?(:created_at), "Response does not have created_at"
		assert resHash[:body][0].has_key?(:updated_at), "Response does not have updated_at"
		assert resHash[:body][0].has_key?(:person_id), "Response does not have person id"
		assert (resHash[:body][0][:card_design_id].eql? @opts[:card_design_id]) , "Invalid card design id #{resHash[:card_design_id]}"
		assert (resHash[:body][0][:id].eql? @opts[:card_id]) , "Invalid card id"
		assert (resHash[:body][0][:card_id].eql? @opts[:card_id]) , "Invalid card id"
		assert (resHash[:body][0][:card_order_id].eql? @opts[:card_order_id]) , "Invalid card order id #{resHash[:body][0][:card_order_id]}"
		assert (resHash[:body][0][:member_id].eql? @opts[:user_id]) , "Invalid member id"
		assert (resHash[:body][0][:person_id].eql? @opts[:card_person_id]) , "Invalid person id"
		
		assert (resHash[:body][0][:links].eql? [{:method=>"POST", :rel=>"load_card", :uri=>"/cards/#{@opts[:card_id]}/load_card"}]) , "Invalid links" #PT-108808094
	end
	
	#M5 - S1 - #49
	it 'A logged in member can check his card load amount limit' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		res = @apiUser.cardService.check_card_limits
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:auth_bal), "Response does not have auth_bal"
		assert resHash.has_key?(:freq_amt_available), "Response does not have freq_amt_available"
		assert resHash.has_key?(:freq_days), "Response does not have freq_days"
		assert resHash.has_key?(:freq_loads_available), "Response does not have freq_loads_available"
		assert resHash.has_key?(:l_exp_date), "Response does not have l_exp_date"
		assert resHash.has_key?(:max_load_amount), "Response does not have max_load_amount"
		assert resHash.has_key?(:min_load_amount), "Response does not have min_load_amount"
		assert resHash.has_key?(:status_text), "Response does not have status_text"
		#assert (resHash[:card_design_id].eql? @opts[:card_design_id]) , "Invalid card design id"
	end

	#M5 - S1 - #50
	it 'A logged in member loads funds to his card' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		res = @apiUser.cardService.check_card_limits
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		
		res = @apiUser.cardService.load_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		
		assert resHash.has_key?(:encoded_message), "Response does not have encoded_message"
		assert resHash.has_key?(:merchant_ref_num), "Response does not have merchant_ref_num"
		assert resHash.has_key?(:signature), "Response does not have signature"
		#assert (resHash[:card_design_id].eql? @opts[:card_design_id]) , "Invalid card design id"
	end
	
	#M2
	it 'A logged in member can get card after loading card' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		res = @apiUser.cardService.check_card_limits
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		
		res = @apiUser.cardService.load_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		res = @apiUser.cardService.get
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		assert resHash.has_key?(:activated_at), "Response does not have activated_at"
		assert resHash.has_key?(:created_at), "Response does not have created_at"
		assert resHash.has_key?(:updated_at), "Response does not have updated_at"
		assert resHash.has_key?(:ip_address), "Response does not have ip address"
		assert (resHash[:card_design_id].eql? @opts[:card_design_id]) , "Invalid card design id"
		assert (resHash[:id].eql? @opts[:card_id]) , "Invalid id"
		assert (resHash[:card_id].eql? @opts[:card_id]) , "Invalid card id"
		assert (resHash[:card_order_id].eql? @opts[:card_order_id]) , "Invalid card order id"
		assert (resHash[:city].eql? @opts[:account_city]) , "Invalid city"
		assert (resHash[:member_id].eql? @opts[:user_id]) , "Invalid member id"
		assert (resHash[:person_id].eql? @opts[:card_person_id]) , "Invalid person id"
		assert (resHash[:phone_number].eql? @opts[:account_phone_number]) , "Invalid phone number"
		assert (resHash[:postal_code].eql? @opts[:account_postal_code]) , "Invalid postal code"
		assert (resHash[:province].eql? @opts[:account_province]) , "Invalid province"
		assert (resHash[:suite].eql? @opts[:account_suite]) , "Invalid suite"
	
	end

	#M4 - S1 - #43
	it 'A logged in member cannot activate card more than once' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		res = @apiUser.cardService.activate_card
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_activate_card_controller_card_already_activated") , "Invalid error key #{resHash[:errors][0]}"
		assert (resHash[:errors][0][:msg].eql? "ActivateCardController::CardAlreadyActivated") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
	end
	
	#M4 - S2 - #44
	it 'A logged in member cannot activate card with invalid proxy number' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		#invalid proxy key 13 int length
		@opts[:card_proxy_key] = '1234567890123'
		
		res = @apiUser.cardService.activate_card
		assert res.code == 404, "Invalid response code #{res}, should be 404-Resource not found"
		resHash = JSON.parse(res.body, symbolize_names: true)

		assert (resHash[:errors][0][:property].eql? "") , "Invalid property which should be blank"
		assert (resHash[:errors][0][:key].eql? "card_service_activate_card_controller_no_card_found_for_member") , "Invalid key which should be card_activate_card_controller_no_card_found_for_member"
		assert (resHash[:errors][0][:msg].eql? "ActivateCardController::NoCardFoundForMember"), "Error message is not valid"
	end

	#M4 - S3 - Need Fraud and Equifax to respond with failure for credit app to test this
	#"fraud_verification_status" != "accept"
	#M4 - S4 - refers to activation failure response when connecting to Fraud or Equifax
	#M4 - S5 - refers to pin failure response when connecting to Fraud or Equifax
	
	#M4 - Addnl - #45 - Security test
	it 'A logged in member cannot activate card with others card id' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		@opts.store(:card_id, 1)
		res = @apiUser.cardService.activate_card
		assert res.code == 404, "Invalid response code #{res}, should be 404-Resource nt found - PT# #106988844"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_activate_card_controller_no_card_found_for_member") , "Invalid error key"
		assert (resHash[:errors][0][:msg].eql? "ActivateCardController::NoCardFoundForMember") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
		
		#logout
		res = @apiUser.memberService.logout
		assert res.code == 200, "Response code is not 200, https://www.pivotaltracker.com/story/show/102683354"
	end
	
	#M4 - Addnl - #46
	it 'A logged in member cannot activate card with invalid card id' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		#usually 2000 is not likely to be reached in testing, if not update it to something not created yet
		@opts.store(:card_id, 2000)
		res = @apiUser.cardService.activate_card
		assert res.code == 404, "Invalid response code #{res}, should be 404-Resource not found"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_activate_card_controller_no_card_found_for_member") , "Invalid error key"
		assert (resHash[:errors][0][:msg].eql? "ActivateCardController::NoCardFoundForMember") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
		
		#logout
		#res = @apiUser.memberService.logout
		#assert res.code == 200, "Response code is not 200, https://www.pivotaltracker.com/story/show/102683354"
	end
	
	#M4 - S2 - #47
	it 'A logged in member cannot activate card with invalid proxy number length' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		#invalid proxy key
		@opts[:card_proxy_key] = '123'
		
		res = @apiUser.cardService.activate_card
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)

		assert (resHash[:errors][0][:property].eql? "proxy_key") , "Invalid property which should be proxy_key"
		assert (resHash[:errors][0][:key].eql? "pattern") , "Invalid key which should be pattern"
		assert (resHash[:errors][0][:msg].eql? "Does not match pattern '^\\d{13}'"), "Error message is not valid #{resHash[:errors]}"
	end

	#M1-Addnl
	it 'A logged in member cannot create card more than once for now' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"
		
		res = @apiUser.cardService.create
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_create_card_controller_only_one_card_allowed_per_mogo_member") , "Invalid error key #{resHash[:errors][0]}"
		assert (resHash[:errors][0][:msg].eql? "CreateCardController::OnlyOneCardAllowedPerMogoMember") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
	end	

	#M3-Addnl - #40
	it 'A logged in member cannot add card with invalid card design id data type' do
		#create card 
		@opts.store(:card_design_id, "1")
		res = @apiUser.cardService.create
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "invalid_type") , "Invalid error key #{resHash[:errors]}"
		assert (resHash[:errors][0][:msg].eql? "Invalid type. Expected: integer, given: string"), "Error message is not valid #{resHash[:errors]}"
		assert (resHash[:errors][0][:property].eql? "card_design_id") , "Invalid error property"
	end
	
	#M3-Addnl - #41
	it 'A logged in member cannot add card with invalid card design id' do
		@opts.store(:card_design_id, 2)
		res = @apiUser.cardService.create
		assert res.code == 404, "Invalid response code #{res}, should be 404-Resource not found"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "card_service_create_card_controller_card_design_not_found") , "Invalid error key"
		assert (resHash[:errors][0][:msg].eql? "CreateCardController::CardDesignNotFound") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "") , "Invalid error property"
	end

	#M5 - 54 Addnl
	it 'A logged in member cannot loads funds of card amount of string data type to his card' do
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res.inspect}, should be 200-OK"

		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.check_card_limits
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		#@opts.store(:card_amount, 450)
		@opts.store(:card_amount, "string")
		
		res = @apiUser.cardService.load_card
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "invalid_type") , "Invalid error key #{resHash[:errors][0]}"
		assert (resHash[:errors][0][:msg].eql? "Invalid type. Expected: number, given: string") , "Invalid error msg #{resHash[:errors]}"
		assert (resHash[:errors][0][:property].eql? "amount") , "Invalid error property"
	end

	#M5 - 55 Addnl
	it 'A logged in member cannot load funds of card proxy key of string data type to his card' do
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.check_card_limits
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		#@opts.store(:card_amount, 450)
		@opts.store(:card_proxy_key, "string")
		
		res = @apiUser.cardService.load_card
		require 'pry'
		binding.pry
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "pattern") , "Invalid error key #{resHash[:errors][0]}"
		assert (resHash[:errors][0][:message].eql? "Does not match pattern '^\\d{13}'") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "proxy_key") , "Invalid error property #{resHash[:errors][0]}"
	end

	#M6 - 21 
	it 'A logged in member can get bank info' do
		#create card application

		res = @apiUser.cardService.get_bank_list
		
		#require 'pry'
		#binding.pry

		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		res = @apiUser.cardService.activate_card
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"

		res = @apiUser.cardService.check_card_limits
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		
		#@opts.store(:card_amount, 450)
		@opts.store(:card_proxy_key, "string")
		
		res = @apiUser.cardService.load_card
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "pattern") , "Invalid error key #{resHash[:errors][0]}"
		assert (resHash[:errors][0][:message].eql? "Does not match pattern '^\\d{13}'") , "Invalid error msg"
		assert (resHash[:errors][0][:property].eql? "proxy_key") , "Invalid error property #{resHash[:errors][0]}"
	end
	
	#M6 - PT# 110096068 - AC5 - 22
	it 'A logged in member cannot create card with alphabets in PIN' do
		#puts "Email id - '#{@opts[:user_email]}'"
		#create card application
		@opts[:card_pin] = "abc1"
		res = @apiUser.cardService.create
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "json_schema_error_pattern") , "Invalid error key #{resHash}"
		assert (resHash[:errors][0][:msg].eql? "The property '#/new_pin' value \"#{@opts[:card_pin]}\" did not match the regex '^\\d{4}' in schema file:///fis_service/schemas/set_pin-schema.json#") , "Invalid error msg #{resHash}"
		assert (resHash[:errors][0][:property].eql? "fis") , "Invalid error property #{resHash}"
	end

	#M6 - PT# 110096068 - AC5 - 23
	it 'A logged in member cannot create card with special chars in PIN' do
		#puts "Email id - '#{@opts[:user_email]}'"
		#create card application
		@opts[:card_pin] = "#123"
		res = @apiUser.cardService.create
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "json_schema_error_pattern") , "Invalid error key #{resHash}"
		assert (resHash[:errors][0][:msg].eql? "The property '#/new_pin' value \"#{@opts[:card_pin]}\" did not match the regex '^\\d{4}' in schema file:///fis_service/schemas/set_pin-schema.json#") , "Invalid error msg #{resHash}"
		assert (resHash[:errors][0][:property].eql? "fis") , "Invalid error property #{resHash}"
	end

	#M6 - 24 - Addnl
	it 'A logged in member cannot create card with PIN having invalid data type' do
		#puts "Email id - '#{@opts[:user_email]}'"
		#create card application
		@opts[:card_pin] = 1234
		res = @apiUser.cardService.create
		assert res.code == 400, "Invalid response code #{res}, should be 400-Bad request"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:errors][0][:key].eql? "invalid_type") , "Invalid error key #{resHash}"
		assert (resHash[:errors][0][:message].eql? "Invalid type. Expected: string, given: integer") , "Invalid error msg #{resHash}"
		assert (resHash[:errors][0][:property].eql? "pin") , "Invalid error property #{resHash}"
	end

	#M6 - PT# 110096068 - AC5 - 25
	it 'A logged in member can get his PIN after create card' do
		#puts "Email id - '#{@opts[:user_email]}'"
		#create card application
		res = @apiUser.cardService.create
		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		
		res = @apiUser.cardService.get_pin

		#require 'pry'
		#binding.pry

		assert res.code == 200, "Invalid response code #{res}, should be 200-OK"
		assert (resHash[:errors][0][:key].eql? "json_schema_error_pattern") , "Invalid error key #{resHash}"
		assert (resHash[:errors][0][:msg].eql? "The property '#/new_pin' value \"#{@opts[:card_pin]}\" did not match the regex '^\\d{4}' in schema file:///fis_service/schemas/set_pin-schema.json#") , "Invalid error msg #{resHash}"
		assert (resHash[:errors][0][:property].eql? "fis") , "Invalid error property #{resHash}"
	end

end

