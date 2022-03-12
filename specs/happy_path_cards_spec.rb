require_relative '../lib/ApiLib'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/reporters'

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
			
testdata = ApiDefaultTestData.NewDefaultHash(Hash.new)
describe 'Happy Path - Cards' do

	#let's define our class variables just once
	if !class_variable_defined?(:@@member) then
		@@member = ApiUser.new(testdata)

		@@skipTheRest = false
	end

	def self.test_order
		:alpha
	end

	def teardown
		#if pass
		if(self.result_code.eql?('.'))
		else
		  @@skipTheRest = true
		end
		super()
	end

	def setup
		if(@@skipTheRest==true) 
		  skip("pre-requisite step failed")
		end
		super()
	end

	it 'Member sign up' do
		res = @@member.memberService.signup
		assert res.code == 200, "Invalid response code #{res.code}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert (resHash[:email_address].inspect.include? testdata[:user_email]) , "Invalid email address - #{resHash[:email_address].inspect}"
		assert (!resHash[:opt_in_email_date].inspect.include? 'nil') , "Invalid opt in email date - #{resHash[:opt_in_email_date].inspect}"
		assert resHash.has_key?(:signup_ip_address)
		assert resHash.has_key?(:unconfirmed_email)
		assert resHash.has_key?(:updated_at)
		assert resHash.has_key?(:"uuid")
		assert resHash.has_key?(:"links")
	end

	it 'Member activate' do
		res = @@member.memberService.activate
		assert res.code == 200, "Invalid response code #{res.code}, should be 200-OK"
	end

	it 'Member login and get account' do
		res = @@member.memberService.login
		assert res.code == 200, "Invalid response code #{res.code}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
	
		#assert resHash.has_key?(:"member_uuid")
		assert resHash.has_key?(:"member_id")
		assert resHash.has_key?(:"auth_token")
		#todo could assert the value of ttl
		#assert resHash.has_key?(:"ttl_in_seconds")
		assert resHash.has_key?(:"links")
		
		assert (resHash[:email_address].inspect.include? testdata[:user_email]) , "Invalid email address - #{resHash[:email_address].inspect}"
		#assert resHash.has_key?(:member_uuid)

		#debug
		puts '<debug2_for_crm_team_use>'
		puts resHash.inspect
		puts '</debug2_for_crm_team_use>'		

		res = @@member.memberService.get_account
		assert res.code == 200

		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:"links")
	end

	#M1-S1
	it 'A logged in member can create a card application' do
		res = @@member.cardApplicationService.create
		assert res.code == 200, "Invalid response code #{res.code}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash.has_key?(:"id")
		testdata[:card_application_id] = resHash[:id]
		assert (resHash[:id].inspect.include? testdata[:credit_application_id].to_s) , "Invalid card application id"
		assert (resHash[:first_name].inspect.include? testdata[:card_first_name]) , "Invalid first name"
		assert (resHash[:last_name].inspect.include? testdata[:card_last_name]) , "Invalid last name"
		assert (resHash[:birth_date].inspect.include? testdata[:card_birth_date]) , "Invalid birth date"
		assert (resHash[:address].inspect.include? testdata[:card_address]) , "Invalid address"
		assert (resHash[:suite].inspect.include? testdata[:card_suite]) , "Invalid suite"
		assert (resHash[:city].inspect.include? testdata[:card_city]) , "Invalid city"
		assert (resHash[:province].inspect.include? testdata[:card_province]) , "Invalid province"
		assert (resHash[:postal_code].inspect.include? testdata[:postal_code].to_s) , "Invalid postal code"
	end

	#M3-S1 - #34
	it 'A logged in member can submit answers to KYC questions' do
		res = @@member.cardApplicationService.submit_answers_to_kyc_questions
		assert res.code == 200
		resHash = JSON.parse(res.body, symbolize_names: true)
		
		assert resHash.has_key?(:created_at), "Response does not have created_at"
		assert resHash.has_key?(:ip_address), "Response does not have ip_address"
		assert (resHash[:id].eql? testdata[:card_application_id]) , "Invalid card application id"
		assert (resHash[:first_name].eql? testdata[:card_first_name]) , "Invalid first name"
		assert (resHash[:last_name].eql? testdata[:card_last_name]) , "Invalid last name"
		assert (resHash[:birth_date].eql? testdata[:card_birth_date]) , "Invalid birth date"
		assert (resHash[:address].eql? testdata[:card_address]) , "Invalid address"
		assert (resHash[:suite].eql? testdata[:card_suite]) , "Invalid suite"
		assert (resHash[:city].eql? testdata[:card_city]) , "Invalid city"
		assert (resHash[:province].eql? testdata[:card_province]) , "Invalid province"
		assert (resHash[:fraud_verification_status].eql? "accept") , "Invalid fraud_verification_status"
		assert (resHash[:kyc_answers_response].eql? "approved") , "Invalid kyc_answers_response"
		assert (resHash[:kyc_attempts].eql? 1) , "Invalid kyc_attempts"
		assert (resHash[:kyc_request_response].eql? "pending") , "Invalid kyc_request_response"
		assert (resHash[:kyc_status].eql? nil) , "Invalid kyc_status"
	end

	it 'Waiting' do
		sleep(3)
	end
	
	#M3-S1
	it 'A logged in member can add card after card application' do
		res = @@member.cardApplicationService.create_card
		assert res.code == 200, "Invalid response code #{res.code}, should be 200-OK - https://www.pivotaltracker.com/story/show/101140462"
		resHash = JSON.parse(res.body, symbolize_names: true)
		assert resHash[:card_application].has_key?(:created_at), "Response does not have created_at"
		assert resHash[:card_application].has_key?(:ip_address), "Response does not have ip_address"
		assert (resHash[:card_application_id].eql? testdata[:card_application_id]) , "Invalid card application id"
		assert (resHash[:id].eql? testdata[:card_id]) , "Invalid card id"
		assert (resHash[:card_application][:first_name].eql? testdata[:card_first_name]) , "Invalid first name"
		assert (resHash[:card_application][:last_name].eql? testdata[:card_last_name]) , "Invalid last name"
		assert (resHash[:card_application][:birth_date].eql? testdata[:card_birth_date]) , "Invalid birth date"
		assert (resHash[:card_application][:address].eql? testdata[:card_address]) , "Invalid address"
		assert (resHash[:card_application][:suite].eql? testdata[:card_suite]) , "Invalid suite"
		assert (resHash[:card_application][:city].eql? testdata[:card_city]) , "Invalid city"
		assert (resHash[:card_application][:province].eql? testdata[:card_province]) , "Invalid province"
		assert (resHash[:card_application][:fraud_verification_status].eql? "accept") , "Invalid fraud_verification_status"
		assert (resHash[:card_application][:kyc_answers_response].eql? "approved") , "Invalid kyc_answers_response"
		assert (resHash[:card_application][:kyc_attempts].eql? 1) , "Invalid kyc_attempts"
		assert (resHash[:card_application][:kyc_request_response].eql? "pending") , "Invalid kyc_request_response"
		assert (resHash[:card_application][:kyc_status].eql? nil) , "Invalid kyc_status"
	end

	#M4 - S1 - #43
	it 'A logged in member can activate card after card application' do
		res = @@member.cardApplicationService.activate_card
		assert res.code == 200, "Invalid response code #{res.code}, should be 200-OK"
		resHash = JSON.parse(res.body, symbolize_names: true)

		assert resHash.has_key?(:activated_at), "Response does not have activated_at"
		assert resHash.has_key?(:created_at), "Response does not have created_at"
		assert resHash.has_key?(:updated_at), "Response does not have updated_at"
		assert resHash.has_key?(:person_id), "Response does not have person id"
		assert (resHash[:card_design_id].eql? testdata[:card_design_id]) , "Invalid card design id"
		assert (resHash[:card_application_id].eql? testdata[:card_application_id]) , "Invalid card application id"
		assert (resHash[:id].eql? testdata[:card_id]) , "Invalid card id"
		assert (resHash[:member_id].eql? testdata[:user_id]) , "Invalid member id"
		assert (resHash[:person_id].eql? testdata[:card_person_id]) , "Invalid person id"
		assert (resHash[:pin].eql? testdata[:card_pin]) , "Invalid pin"
		assert (resHash[:proxy_key].eql? testdata[:card_proxy_key]) , "Invalid proxy key"
	end

end

