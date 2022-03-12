require 'httparty'

HTTParty::Basement.default_options.update(verify: false)

class ServiceBase
    
  def initialize(data)
    @data = data
    @pollingPath = ''
    @route = ''
  end

  def GetPathPrefix
    @data[:protocol] + '://' + @data[:host]
    #@data[:protocol] + '://' + @data[:host] + ':' + @data[:port]
  end

  def Url
    GetPathPrefix() + @route
  end

  def GetPollingPath
    GetPathPrefix() + @pollingPath
  end

  def Headers(auth_token = nil)
     headers = { "Content-Type" => "application/json; charset=UTF-8" }
     #headers['X-Auth-Token'] = @data[:auth_token] if @data[:auth_token]
  end

  def MultiPartHeaders(auth_token = nil)
    headers = { "Content-Type" => "multipart/form-data" }
    headers['X-Auth-Token'] = @data[:auth_token] if @data[:auth_token]
    headers['Cookie'] = 'X-Auth-Token=' + @data[:auth_token] if @data[:auth_token]
  end

  def PollingGET()
      res = Get()

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

  def Get (url=Url(), headers=Headers())
    HTTParty.get(url, headers: headers)
  end

  def PollResource()
	  poll_attempts = @data[:test_poll_attempts]
	  poll_interval_seconds = @data[:test_poll_interval_seconds]
    response = nil
	  poll_attempts.times do
		  response = Get(GetPollingPath(), Headers(@data[:auth_token]))

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
