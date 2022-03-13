require 'httparty'
require 'net/http'

HTTParty::Basement.default_options.update(verify: false)
class ServiceBase
  public

  attr_accessor :data
  attr_accessor :route

  def initialize(data)
    @data = data
    @route = ''
  end

  def GetPathPrefix
    @data[:protocol] + '://' + @data[:host]
    #@data[:protocol] + '://' + @data[:host] + ':' + @data[:port]
  end

  def Url
    GetPathPrefix() + @route
  end

  def Headers auth_token = nil
    { "Content-Type" => "application/json; charset=UTF-8" }
    #headers['X-Auth-Token'] = @data[:auth_token] if @data[:auth_token]
  end

  def GET()
    Net::HTTP.get URI(Url())
    #, port = @data[:port])
    #Net::HTTP.get_response(URI(Url()), headers: Headers(), port: @data[:port])
    #HTTParty.get Url(), headers: Headers()
  end

  def POST requestBody
    #HTTParty.post Url(), body: requestBody.to_json(), headers: Headers(), verify: false
    Net::HTTP.post URI(Url()), data = requestBody.to_json(), header = Headers()
  end

  def PUT requestBody
    HTTParty.put Url(), body: requestBody.to_json(), headers: Headers()
  end

  def PATCH requestBody
    HTTParty.patch Url(), body: requestBody.to_json(), headers: Headers()
  end

  def DELETE
    HTTParty.delete Url(), headers: Headers()
  end


end
