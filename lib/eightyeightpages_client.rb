require 'eightyeightpages_client/version'
require 'httparty'

module EightyeightpagesClient
  class Query
    include HTTParty
    attr_accessor :account_name, :referer

    def initialize(account_name, referer)
      self.account_name = account_name
      self.referer = referer
      self.class.base_uri "#{account_name}.88pages.com"
    end

    def unescape(value)
      case value
      when Array
        value.map { |v| unescape(v) }
      when Hash
        Hash[value.map { |k, v| [k, unescape(v)] }]
      else
        if value.is_a?(String)
          CGI::unescape(value)
        else
          value
        end
      end
    end

    def method_missing(form, *args)
      begin
        unescape self.class.get("/api/forms/#{form.to_s.gsub('_', '-')}/entries.json?referer=#{referer}").parsed_response
      rescue
        rescue super(field, *args)
      end
    end
  end
end
