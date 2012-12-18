module SalesforceAPI

  class ConnectionException < StandardError; end
  class ErrorReceivedException < StandardError; end

  class Caller

    attr_reader :api_version, :username, :password, :client_id, :client_secret, :host, :instance_url, :id, :issued_at, :access_token, :signature

    def initialize options = {} 
      @api_version = options[:api_version] ||= ENV["SALESFORCE_API_VERSION"] 
      @username = options[:username] ||= ENV["SALESFORCE_USERNAME"]
      @password = options[:password] ||= ENV["SALESFORCE_PASSWORD"]
      @client_id = options[:client_id] ||= ENV["SALESFORCE_CLIENT_ID"]
      @client_secret = options[:client_secret] ||= ENV["SALESFORCE_CLIENT_SECRET"]
      @host = options[:host] ||= ENV["SALESFORCE_HOST"]
      begin
        parse_authorization_response( Net::HTTP.new(@host, 443).tap { |http|
          http.use_ssl = true
        }.post("/services/oauth2/token", token_request_parameters.to_query).body)
      rescue Errno::ECONNREFUSED
        raise ConnectionException, "Connection problem, did you supply a host?"
      end
    end

    def attachment name, id
      http_get( URI("#{instance_url}/services/data/v#{api_version}/sobjects/#{name}/#{id}/body")).body
    end

    def http_get uri
      req = Net::HTTP::Get.new(uri.request_uri)
      req["Authorization"] = "Bearer #{access_token}"
      Net::HTTP.start(uri.hostname, uri.port, :use_ssl => true) do |http|
        http.request(req)
      end
    end

    def sobject name, id, fields = ""
      uri = URI("#{instance_url}/services/data/v#{api_version}/sobjects/#{name}/#{id}")
      uri.query = {:fields => fields}.to_query unless fields.empty?
      http_get(uri).body
    end

    def query query_string
      uri = URI("#{instance_url}/services/data/v#{api_version}/query")
      uri.query = "q=#{URI::escape(query_string)}"
      http_get(uri).body
    end

    def token_request_parameters
      @token_request_parameters.nil? ? @token_request_parameters = {
        :grant_type => "password",
        :username => @username,
        :password => @password,
        :client_id => @client_id,
        :client_secret => @client_secret
      }.delete_if{|k,v| v.to_s.empty?} : @token_request_parameters
    end

    private

    def parse_authorization_response json
      hash = JSON.parse(json)
      raise ErrorReceivedException, "Authentication error: #{hash["error"]}" if hash["error"]
      @instance_url = hash["instance_url"]
      @id = hash["id"]
      @issued_at = hash["issued_at"]
      @access_token = hash["access_token"]
      @signature = hash["signature"]
    end

  end
end
