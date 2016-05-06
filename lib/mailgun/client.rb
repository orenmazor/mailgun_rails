require 'rest_client'


module Mailgun
  class Client
    attr_reader :api_key, :domain

    # RestClient#post will raise on error, and swallow the action mailgun exception
    # so we wrap here and capture that information
    class SendError < Exception
      def initialize(http_code, response_message)
        @http_code = http_code
        @response_message = response_message
      end

      def to_s
        "#{@http_code} - #{@response_message}"
      end
    end

    def initialize(api_key, domain)
      @api_key = api_key
      @domain = domain
    end

    def send_message(options)
      begin
        RestClient.post mailgun_url, options
      rescue RestClient::Exception => ex
        # there's the temptation to try and parse the response JSON.
        # fight this tempation.
        raise SendError.new(ex.http_code, ex.response.body)
      end
    end

    def mailgun_url
      api_url+"/messages"
    end

    def api_url
      "https://api:#{api_key}@api.mailgun.net/v3/#{domain}"
    end
  end
end
