require 'net/http'
require 'uri'
require "active_support/core_ext/object/to_query"
require "json"
require "active_support/core_ext/hash/indifferent_access"
require 'salesforce-api/caller'

module SalesforceAPI
  def self.api_versions host = "na1.salesforce.com"
    JSON.parse(Net::HTTP.get(host, "/services/data"))
  end
end
