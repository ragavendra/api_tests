HTTParty::Basement.default_options.update(verify: false)

class ServiceBase
    
  def initialize(opts)
    @opts = opts
    @pollingPath = ''
    @resourePath = ''
  end

  def GetPathPrefix
    @opts[:protocol] + '://' + @opts[:host] + ':' + @opts[:port]
  end

  def Url
     GetPathPrefix() + @resourcePath
  end

  def GetPollingPath
    GetPathPrefix() + @pollingPath
  end

  def Headers(auth_token = nil)
     headers = { "Content-Type" => "application/json", "Accept" => "application/vnd.mogo.v2" }
     headers['X-Auth-Token'] = @opts[:auth_token] if @opts[:auth_token]
  end

  def MultiPartHeaders(auth_token = nil)
    headers = { "Content-Type" => "multipart/form-data", "Accept" => "application/vnd.mogo.v2" }
    headers['X-Auth-Token'] = @opts[:auth_token] if @opts[:auth_token]
    headers['Cookie'] = 'X-Auth-Token=' + @opts[:auth_token] if @opts[:auth_token]
  end

  def PollingGET()
      res = Get

      if res.code != 202
        return res
      end

      res_hash = JSON.parse(res.body, symbolize_names: true) if res.body

      @pollingPath = res_hash[:polling_url]
      PollResource() 
  end

  def PollingPOST(requestBody)

      res = HTTParty.post(
        Url(),
        body: requestBody.to_json(),
        headers: Headers(),
        verify: false
      )

      if res.code != 202
        return res
      end

      res_hash = JSON.parse(res.body, symbolize_names: true) if res.body

      @pollingPath = res_hash[:polling_url]
      PollResource() 
  end

  def PollingPUT(requestBody)

      res = HTTParty.put(
        Url(),
        body: requestBody.to_json(),
        headers: Headers()
      )

      if res.code != 202
        return res
      end

      res_hash = JSON.parse(res.body, symbolize_names: true) if res.body

      @pollingPath = res_hash[:polling_url]
      PollResource()
  end

  def PollingDELETE()

      res = HTTParty.delete(
        Url(),
        headers: Headers()
      )

      if res.code != 202
        return res
      end

      res_hash = JSON.parse(res.body, symbolize_names: true) if res.body

      @pollingPath = res_hash[:polling_url]
      PollResource() 
  end

  def PollingMultiPartPOST(requestBody)

      res = MogoHttpClient.post(
        Url(),
        body: requestBody,
        headers: MultiPartHeaders(),
        verify: false
      )

      if res.code != 202
        return res
      end

      res_hash = JSON.parse(res.body, symbolize_names: true) if res.body

      @pollingPath = res_hash[:polling_url]
      PollResource() 
  end

  def Get (url=Url(), headers=Headers())
    HTTParty.get(url, headers: headers)
  end

  def PollResource()
	  poll_attempts = @opts[:test_poll_attempts]
	  poll_interval_seconds = @opts[:test_poll_interval_seconds]
    response = nil
	  poll_attempts.times do
		  response = Get(GetPollingPath(), Headers(@opts[:auth_token]))

      if response.code == 202       
        sleep(poll_interval_seconds)
      else
        break
        #return response
      end
	  end

    response
  end

end
