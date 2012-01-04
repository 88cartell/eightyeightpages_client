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

    def unescape(hash)
      if hash.is_a?(Array)
        hash.each do |value|
          unescape hash
        end
      elsif hash.is_a?(Hash)
        hash.keys.each do |key|
          if hash[key].is_a?(String)
            hash[key] = CGI::unescape(hash[key])
          elsif hash[key].is_a?(Hash) or hash[key].is_a?(Array)
            unescape hash[key]
          end
        end
      end
      hash
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
