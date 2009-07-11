require 'cgi'
require 'httparty'

module PlugNPay

  # A Ruby class for remote client use of the PlugNPay HTTP API.
  class Service

    include HTTParty
    format :html
    
    attr_accessor :api_url, :publisher_name, :debug

    # Performs a merchant authorization using the PlugNPay HTTP API.
    # 
    # Example:
    #   PlugNPay::Service.new('publisher-name'=>'youraccount').
    def initialize(params={})
      self.api_url = 'https://pay1.plugnpay.com/payment/pnpremote.cgi'
      self.publisher_name = params['publisher-name'] if params['publisher-name']
      self.debug = params['debug'] if params['debug']
    end
  
    # Performs a merchant authorization using the PlugNPay HTTP API.
    # 
    # Example:
    #   PlugNPay::Service.new('publisher-name'=>'youraccount').
    #     authorize('card-number' => '4111111111111111',
    #       'card-name' => 'cardtest', 'card-name' => 'Visa',
    #       'card-amount' => '1', 'card-exp' => '01/10')  
    def authorize(params)

      query = {
        'publisher-name' => publisher_name,
        'mode' => 'auth'
      }

      # Set up HTTP request query parameters from method parameters.
      possible_params = %w(card-number card-name card-type card-amount card-exp card-cvv
        email ship-name address1 address2 city state zip country)
      possible_params.each do |param|
        query[param] = CGI.unescape(params[param]) if params[param]
      end

      # Perform HTTP request.
      response_string = Service.post(api_url, :query => query)
      puts CGI.unescape(response_string.gsub(/\&/,"\n")) if debug
      
      # Parse HTTP response into a Ruby hash.
      response_values = response_string.split(/\&/)
      response = Hash[*response_values.collect {|value|
        [value.match(/^(.*)\=/)[1], value.match(/\=(.*)$/)[1]] }.flatten]
      
      # Raise errors if necessary.
      case response['FinalStatus']
        when /badcard/i
          raise BadCard
        when /problem/i
          raise Problem
        else
          # Return the response.
          response
      end
    end

  end

  # Authorizations raise this error when the FinalStatus from PlugNPay is "badcard"
  class BadCard < StandardError; end

  # Authorizations raise this error when the FinalStatus from PlugNPay is "problem"
  class Problem < StandardError; end

  # Authorizations raise this error when the FinalStatus from PlugNPay is "fraud"
  class Fraud < StandardError; end
  
end
