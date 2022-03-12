class CardService < ServiceBase

	def initialize(opts)
		super(opts)
		@resourcePath = "/cards"
	end

	def get 
		@resourcePath = "/cards/#{@opts[:card_id]}"
		PollingGET()
	end

	def get_bank_list
		@resourcePath = "/cards/supported_banks"
		PollingGET()
	end
	
	def get_pin 
		@resourcePath = "/cards/#{@opts[:card_id]}/get_pin"
		PollingGET()
	end

	def create
		@resourcePath = "/cards"
			#@opts[:user_id] = resHash[:id]
		req = { 
			#card_application_id: @opts[:card_application_id],
			card_design_id: @opts[:card_design_id],
			pin: @opts[:card_pin] 
		}
		res =  PollingPOST(req)
		
		if res.code == 200
			response_hash = JSON.parse(res.body, symbolize_names: true) if res.body
			@opts.store(:card_id, response_hash[:card_id])
			@opts.store(:card_order_id, response_hash[:card_order_id])
			@opts.store(:card_proxy_key, response_hash[:proxy_key])
		end
		
		res
	end
	#alias_method	:create_card	:create

	def activate_card
		@resourcePath = "/cards/#{@opts[:card_id]}/activate"
		req = { 
			card_id: @opts[:card_id],
			proxy_key: @opts[:card_proxy_key]
		}
		res =  PollingPOST(req)
		
		if res.code == 200
			response_hash = JSON.parse(res.body, symbolize_names: true) if res.body
			@opts.store(:card_pin, response_hash[:pin])
			@opts.store(:card_person_id, response_hash[:person_id])
		end
		
		res
	end

	def index_cards
		@resourcePath = "/cards/index"
		PollingGET()
	end

	def load_card
		@resourcePath = "/cards/#{@opts[:card_id]}/load_card"
		req = { 
			amount: @opts[:card_amount],
			proxy_key: @opts[:card_proxy_key]
		}
		res =  PollingPOST(req)
		
		if res.code == 200
			response_hash = JSON.parse(res.body, symbolize_names: true) if res.body
			@opts.store(:card_encoded_message, response_hash[:encoded_message])
			@opts.store(:card_merchant_ref_num, response_hash[:merchant_ref_num])
			@opts.store(:card_signature, response_hash[:signature])
		end
		
		res
	end

	def check_card_limits
		@resourcePath = "/cards/#{@opts[:card_id]}/check_card_limits"
		req = { 
			proxy_key: @opts[:card_proxy_key]
		}
		res =  PollingPOST(req)
		
		if res.code == 200
			response_hash = JSON.parse(res.body, symbolize_names: true) if res.body
			@opts.store(:card_auth_bal, response_hash[:auth_bal])
			@opts.store(:card_freq_amt_available, response_hash[:freq_amt_available])
			@opts.store(:card_freq_days, response_hash[:freq_days])
			@opts.store(:card_freq_days_available, response_hash[:freq_days_available])
			@opts.store(:card_l_exp_date, response_hash[:l_exp_date])
			@opts.store(:card_max_load_amount, response_hash[:max_load_amount])
			@opts.store(:card_min_load_amount, response_hash[:min_load_amount])
			@opts.store(:card_status_text, response_hash[:status_text])
		end
		res
	end


end
