require_relative 'unique'

class ApiDefaultTestData

	def self.NewDefaultHash(user_data)
		data = Hash.new
		#default data with unique requirements
		unique = Unique.instance
		unique.Id(data)

		#test suite defaults
		data.store(:test_poll_attempts,60)
		data.store(:test_poll_interval_seconds,1)
		#data.store(:host,'cards-m2')
		#data.store(:host,'dockervm')
		data.store(:host, ENV['HOST'] || 'dockervm')
		data.store(:rmq_host, ENV['RMQ_HOST'] || 'dockervm')
		data.store(:rmq_vhost, ENV['RMQ_VHOST'] || '/')
		data.store(:port, ENV['HTTP_PORT'] || '443')
		data.store(:protocol,ENV['HTTP_PROTOCOL'] || 'https')
		data.store(:docker_compose_path, ENV['DOCKER_PATH'] || "#{ENV['HOME']}/Documents/gitbase/devops/services/soa/integration")
		data.store(:docker_compose_logger, ENV['DOCKER_LOG'] ||'dev_loggerservice_1')
		data.store(:docker_machine_name, 'default')

		#new member account
		data.store(:account_first_name,'Long')
		data.store(:account_last_name,'Testresp')
		data.store(:account_first_name,'Long')
		data.store(:account_last_name,'Testresp')
		data.store(:account_address, '71 Stationview Pl')
		data.store(:account_city, 'Bolton')
		data.store(:account_suite, '1234')
		data.store(:account_province, 'ON')
		data.store(:account_postal_code, 'L7E 1K9') 
		data.store(:account_birth_date, '1981-11-11')
		data.store(:account_phone_number, '6045510243')
		data.store(:account_residential_status, 'Rent')
		data.store(:account_residential_monthly_cost, 2000)
		data.store(:account_employment_type, 'Employed')
		data.store(:account_months_employed, 9)
		data.store(:account_salary_type, 'Salary')
		data.store(:account_gross_annual_income, 55000)
		data.store(:account_salary_frequency, 'bi_weekly')
		data.store(:account_requested_credit_amount, 2000)
		data.store(:account_credit_purpose, "Vacation/Travel")
	
		#member account defaults
		data.store(:user_email,"mogo.automation+#{data[:test_id]}@gmail.com")
		data.store(:user_new_email,"mogo.automation1+#{data[:test_id]}@gmail.com")
		data.store(:user_pwd,'1q2w3e4r1')
		data.store(:user_reset_password,'2q3w4e5r2')
		data.store(:user_marketing_opt_in,true)
		data.store(:user_agree_to_privacy_policy_and_terms_of_use, true)
		
		#card application info details
		data.store(:card_first_name,'Plane')
		data.store(:card_last_name,'Testpal')
		data.store(:card_birth_date,'1981-11-11')
		data.store(:card_address,'71 Stationview Pl')
		data.store(:card_suite,'')
		data.store(:card_city,'Bolton')
		data.store(:card_province,'ON')
		data.store(:card_postal_code,'L7E 1K9')
		data.store(:card_application_id, 1)
		
		#card details
		data.store(:card_id, 1)
		data.store(:card_transaction_id, 1)
		data.store(:card_design_id, 1)
		data.store(:card_kyc_answers, [5, 5, 5])
		data.store(:card_kyc_questions, '')
		data.store(:card_proxy_key, '1234567890123')
		data.store(:card_pin, '1751')
		data.store(:card_person_id, '123123')
		data.store(:card_amount, 450)
		
		#card load funds
		data.store(:card_auth_bal, 0)
		data.store(:card_freq_amt_available, 0)
		data.store(:card_freq_days, 0)
		data.store(:card_freq_days_available, 0)
		data.store(:card_l_exp_date, "10/18")
		data.store(:card_max_load_amount, 2500)
		data.store(:card_min_load_amount, 0)
		data.store(:card_status_text, "ACTIVE")
	
		#data.store(:path,' ')
		MergeUserOverrides(data,user_data)
		VariableSubstitution(data)
		return data
	end

	def self.MergeUserOverrides(default_data,user_data)
		#todo - merge the user_data over top of the default data so that user can override defaults
		default_data.merge!(user_data)
	end

	def self.VariableSubstitution(data)
		data.each_value {|value| if (value!=nil && value.instance_of?(String) && value.include?('${test_id}')) then value.gsub!('${test_id}',data[:test_id]) end }	
	end

end
