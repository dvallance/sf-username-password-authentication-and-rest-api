# Purpose

I wanted a simple easy way to interact with the [Salesforce REST API](http://www.salesforce.com/us/developer/docs/api_rest/index_Left.htm) using their [Username-Password OAuth Authentication Flow](http://www.salesforce.com/us/developer/docs/api_rest/Content/intro_understanding_username_password_oauth_flow.htm).

# Goal

1. Handle authorization and re-authorization when the callers session token expires.
2. Provide a generic low level method to make API calls, and provide some of the more common calls (so far I have only added a couple which is all I needed).

# Assuptions

I try to never have any, I simple expose the REST API calls in a easy manor and return JSON results.

## Installation

Add this line to your application's Gemfile:

    gem 'sf-username-password-authentication-and-rest-api', :git => "git://github.com/dvallance/sf-username-password-authentication-and-rest-api.git", :require => "salesforce-api" 

Require the code if necessary (note: some frameworks like rails are set to auto-require gems for you by default)

    require 'salesforce-api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sf-username-password-authentication-and-rest-api

## Usage

You need to supply your credentials in one of two ways and instantiate a SalesforceAPI::Caller.

### Version

You can see a list of available Salesforce Rest API Versions like this:

    SalesforceAPI::versions("na1.salesforce.com") # defaults to this host if not supplied.

### Environmental Values
    
    # Example of pointing to a sandbox.
    ENV["SALESFORCE_API_VERSION"] = "26.0" 
    ENV["SALESFORCE_USERNAME"] = "username@mycompany.sandboxname"
    ENV["SALESFORCE_PASSWORD"] = "password"
    ENV["SALESFORCE_CLIENT_ID"] = "client_id"
    ENV["SALESFORCE_CLIENT_SECRET"] = "client_secret"
    ENV["SALESFORCE_HOST"] = "test.salesforce.com" #pointing to a sandbox

    caller = SalesforceAPI::Caller.new

### Directly as Options

_Note:_ options will be used over ENV variables if both are available.

    caller = SalesforceAPI::Caller.new({
      api_version: "26.0",
      username: "username@mycompany.sandboxname",
      password: "password",
      client_id: "client_id", 
      client_secret: "client_secret",
      host: "test.salesforce.com"

    }

### REST API Calls Examples

Once you have a SalesforceAPI::Caller instance you can make calls like this.
    
    # get an object by its type and its id.
    caller.sobject "Communication_Log__c", "a0Ce00000005c9G" 
    caller.sobject "Communication_Log__c", "a0Ce00000005c9G", "Email" # ask for only 1 field instead of all by default 

    # get an attachment
    caller.attachment("Attachment", "00Pe0000000IVTyEAH")
    
    # running a query to get all attachments that belong to a specific parent
    caller.query "Select Id, ParentId, OwnerId, Name, Body From Attachment where ParentId = 'a0Ce00000005b9P'"

    # get a specific attachment as a binary/string
    caller.attachment("Attachment", "00Pe0000000IVTyEAO").class

### Want more API call methods?

This is all I needed for my current project but if there is a demand/need for more let me know I'll add them or better yet contribute!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
