require 'httparty'

module PlugNPay
  class Service

    include HTTParty
    format :html
    
    attr_accessor :api_url,
      :publisher_name

    def initialize(params={})
      self.api_url = 'https://pay1.plugnpay.com/payment/pnpremote.cgi'
      self.publisher_name = params['publisher-name'] unless params['publisher-name'].blank?
    end
  
    # Example:
    #   PlugNPay::Service.new('publisher-name'=>'venuedrive').authorize('card-number' => '4111111111111111',
    #   'card-name' => 'cardtest', 'card-name' => 'Visa', 'card-amount' => '1', 'card-exp' => '01/10')
  
    def authorize(params)
      query = {}
      query['card-number'] = params['card-number'] if params['card-number']
      query['card-name'] = params['card-name'] if params['card-name']
      query['card-type'] = params['card-name'] if params['card-type']
      query['card-amount'] = params['card-amount'] if params['card-amount']
      query['card-exp'] = params['card-exp'] if params['card-exp']
      query['card-cvv'] = params['card-cvv'] if params['card-cvv']
      query['email'] = params['email'] if params['email']
      query['ship-name'] = params['ship-name'] if params['ship-name']
      query['address1'] = params['address1'] if params['address1']
      query['address2'] = params['address2'] if params['address2']
      query['city'] = params['city'] if params['city']
      query['state'] = params['state'] if params['state']
      query['zip'] = params['zip'] if params['zip']
      query['country'] = params['country'] if params['country']

      query['publisher-name'] = publisher_name
      query['mode'] = 'auth'
      # arguments = arguments.map {|argument| ERB::Util::h(argument)}

      require 'cgi'
      puts url_unescape(Service.post(api_url, :query => query).gsub!(/\&/,"\n"))
    end

    def url_unescape(string)
      string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
        [$1.delete('%')].pack('H*')
      end
    end

  end
end
