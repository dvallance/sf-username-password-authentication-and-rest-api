require 'test_helper'

describe SalesforceAPI::Caller do

  describe "not supplying any authentication parameters" do

    it "causes a connection exception if Net:Http.post barfs" do
      Net::HTTP.any_instance.stubs(:post).raises(Errno::ECONNREFUSED)
      -> {SalesforceAPI::Caller.new()}.must_raise SalesforceAPI::ConnectionException
    end

    it "causes a error received exception if there is a json error response" do
      Net::HTTP.any_instance.stubs(:post).returns(stub(:body => '{"error":"unsupported_grant_type"}'))

      -> {SalesforceAPI::Caller.new(:host => "test.salesforce.com" )}.must_raise SalesforceAPI::ErrorReceivedException

    end
  end

  describe "supplying configuration values" do

    before do
      SalesforceAPI::Caller.any_instance.stubs(:authorize)
    end

    it "uses environment variables if no options are supplied" do
      ENV["SALESFORCE_API_VERSION"] = "version" 
      ENV["SALESFORCE_USERNAME"] = "username"
      ENV["SALESFORCE_PASSWORD"] = "password"
      ENV["SALESFORCE_CLIENT_ID"] = "client_id"
      ENV["SALESFORCE_CLIENT_SECRET"] = "client_secret"
      ENV["SALESFORCE_HOST"] = "host"

      caller = SalesforceAPI::Caller.new
      caller.api_version.must_equal "version"
      caller.username.must_equal "username"
      caller.password.must_equal "password"
      caller.client_id.must_equal "client_id"
      caller.client_secret.must_equal "client_secret"
      caller.host.must_equal "host"
    end

    it "uses options over environment variables if they are supplied" do
      caller = SalesforceAPI::Caller.new({
        api_version: "opt_version",
        username: "opt_username",
        password: "opt_password",
        client_id: "opt_client_id", 
        client_secret: "opt_client_secret",
        host: "opt_host"
      })
      caller.api_version.must_equal "opt_version"
      caller.username.must_equal "opt_username"
      caller.password.must_equal "opt_password"
      caller.client_id.must_equal "opt_client_id"
      caller.client_secret.must_equal "opt_client_secret"
      caller.host.must_equal "opt_host"
    end

    describe "#http_get" do
      it "should try and authorize if we receive a HTTPUnauthorized response" do
        caller = SalesforceAPI::Caller.new
        mock_response = mock()
        mock_response.expects(:instance_of?).twice.with(Net::HTTPUnauthorized).returns(true,false)
        Net::HTTP.any_instance.stubs(:start).returns(mock_response)
        caller.expects(:authorize)
        uri = URI("https://www.fake.com")
        response = caller.http_get(uri)
        response.must_equal mock_response
      end

      it "won't try and authorize if we explicitly tell it not too" do
        caller = SalesforceAPI::Caller.new
        mock_response = stub(:instance_of? => true)
        Net::HTTP.any_instance.stubs(:start).returns(mock_response)
        caller.expects(:authorize).never
        uri = URI("https://www.fake.com")
        response = caller.http_get(uri,false)
        response.must_equal mock_response
      end
    end

  end
end
