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

  describe "Temp" do

    it "tokens?" do
      require "./salesforce_config"
      caller = SalesforceAPI::Caller.new
      puts "token = #{caller.access_token}"
      caller.sobject "Communication_Log__c", "a0Ce00000005b9P"
    end

    it "temp testing" do
      skip "temp"
      caller = SalesforceAPI::Caller.new
      puts caller.instance_url
      puts caller.access_token
      puts SalesforceAPI::api_versions

      #puts caller.sobject "Contact", "003e0000002ghih", "Email" 
      puts "============="
      puts caller.sobject "Communication_Log__c", "a0Ce00000005b9P"
      puts "============="
      
      #attachments = JSON.parse(caller.query "Select Id, ParentId, OwnerId, Name, Body From Attachment where ParentId = 'a0Ce00000005b9P'")["records"].collect{|hash| hash["Body"]}
      attachments = JSON.parse(caller.query "Select Id, ParentId, OwnerId, Name, Body From Attachment where ParentId = 'a0Ce00000005b9P'")
      puts attachments.merge("type" => "Attachments")
      puts "============="
      puts caller.attachment("Attachment", "00Pe0000000IVTyEAO")
      #puts caller.sobject "Attachment", "00Pe0000000IVTy"
      #puts caller.attachment "Attachment", "00Pe0000000IVTy" 
      #puts caller.attachment "Attachment", "00Pe0000000IVU3" 
      puts "============="
      puts caller.sobject "Contact", "003e0000002ghihAAA", "Email" 
      puts caller.sobject "Contact", "003e0000002ghihAAA"
    end

  end

  

end
