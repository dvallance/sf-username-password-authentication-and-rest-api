require 'net/http'
require 'uri'
require "active_support/core_ext/object/to_query"
require "json"
require "active_support/core_ext/hash/indifferent_access"
require 'salesforce-api/caller'

# Ruby 1.9.3 introduces "hostname" this provides it for earlier versions of ruby.
class URI::Generic
  if !URI.respond_to?(:hostname) && URI.respond_to?(:host) 
    alias_method :hostname, :host
  end
end

module SalesforceAPI
  def self.api_versions host = "na1.salesforce.com"
    JSON.parse(Net::HTTP.get(host, "/services/data"))
  end
end
