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

    it "temp testing" do
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
