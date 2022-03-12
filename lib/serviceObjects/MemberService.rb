class MemberService < ServiceBase

	def initialize(opts)
		super(opts)
		@resourcePath = '/sessions'
	end

	def login

		@resourcePath = '/sessions'

		req = { 
			email_address: @opts[:user_email],
			password: @opts[:user_pwd]
		}

		res =  PollingPOST(req)

		if res.code == 200
			response_hash = JSON.parse(res.body, symbolize_names: true) if res.body
			@opts.store(:auth_token,response_hash[:auth_token])
		end

		return res
	end


	def logout
		@resourcePath = '/sessions'
		return PollingDELETE()
	end

	def signup
		@resourcePath = '/accounts'

		req = { 
			email_address: @opts[:user_email],
			password: @opts[:user_pwd],
			marketing_opt_in: @opts[:user_marketing_opt_in],
			agree_to_privacy_policy_and_terms_of_use: @opts[:user_agree_to_privacy_policy_and_terms_of_use]
		}

		res = PollingPOST(req)
		resHash = JSON.parse(res.body, symbolize_names: true)

		if res.code == 200
			@opts[:confirmation_token] = resHash[:confirmation_token]
			@opts[:user_id] = resHash[:id]
		end

		return res
	end

	def edit_email

		@resourcePath = '/accounts'

		req = { 
			email_address: @opts[:user_new_email],
		}

		res = PollingPUT(req)
		resHash = JSON.parse(res.body, symbolize_names: true)
		#puts "Result #{res.inspect}"
		#puts "Resource url #{@resourcePath}"
		
		@opts[:user_confirmation_token] = resHash[:confirmation_token]

=begin uncomment if conf token is not in response. This code parses confirmation token from response
		cmd ="docker logs --tail=9 #{@opts[:docker_compose_logger]}"
		ENV["http_proxy"] = ''
		Dir.chdir(@opts[:docker_compose_path]){
			@log_str = %x[#{cmd}]
		}

		puts "Verify pin pos: " + @log_str.index("verification_pin").to_s unless @log_str.index("verification_pin")

		if @log_str.index("confirmation_token")
			str_pos =  @log_str.index("confirmation_token")
			@opts[:user_confirmation_token] = @log_str[(str_pos + 21), 36]
		end
		ENV["http_proxy"] = 'http://localhost:8888'
=end
		return res
	end

	def confirm_email 

		@resourcePath = '/accounts/confirm-email'

		req = { 
			confirmation_token: @opts[:user_confirmation_token]
		}

		return PollingPOST(req)
	end

	def forgot_password
		@resourcePath = '/accounts/forgot-password'

		req = {
			email_address: @opts[:user_email]
		}

		return PollingPOST(req)
	end

	def reset_password(reset_token)
		@resourcePath = '/accounts/reset-password'

		req = {
			password: @opts[:user_reset_password],
			reset_password_token: reset_token
		}

		@opts.delete(:user_pwd)
		@opts.store(:user_pwd,@opts[:user_reset_password])

		return PollingPOST(req)
	end

	def activate
		@resourcePath = '/accounts/activation'

		req = {
			confirmation_token: @opts[:confirmation_token]
		}

		return PollingPOST(req)
	end

	def resend_confirmation
		@resourcePath = '/accounts/resend-activation'

		req = {
			email_address: @opts[:user_email]
		}

		return PollingPOST(req)
	end

	def get_account
		@resourcePath = '/accounts'

		return PollingGET()
	end

	def get_session
		@resourcePath = '/sessions'
		return PollingGET()
	end

	def create_profile
		@resourcePath = '/accounts/profile'

		req = {
			first_name: @opts[:account_first_name],
			last_name: @opts[:account_last_name]
		}
		return PollingPOST(req)
	end

	def edit_profile
		@resourcePath = '/accounts/profile'

		req = {
			first_name: @opts[:account_first_name],
			last_name: @opts[:account_last_name],
			address: @opts[:account_address],
			city: @opts[:account_city],
			suite: @opts[:account_suite],
			province: @opts[:account_province],
			postal_code: @opts[:account_postal_code],
		#	average_paycheck_amount: @opts[:account_average_paycheck_amount],
			birth_date: @opts[:account_birth_date],
			phone_number: @opts[:account_phone_number],
			residential_status: @opts[:account_residential_status],
			residential_monthly_cost: @opts[:account_residential_monthly_cost],
			employment_type: @opts[:account_employment_type],
			months_employed: @opts[:account_months_employed],
			salary_type: @opts[:account_salary_type],
			gross_annual_income: @opts[:account_gross_annual_income],
			salary_frequency: @opts[:account_salary_frequency],
			requested_credit_amount: @opts[:account_requested_credit_amount]
			#requested_credit_purpose: @opts[:account_credit_purpose]
		}
		return PollingPUT(req)
	end
end

