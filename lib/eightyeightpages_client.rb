require "eightyeightpages_client/version"

module EightyeightpagesClient
  class Query
    include HTTParty
    attr_accessor :account_name, :referer

    def initialize(account_name, referer)
      self.account_name = account_name
      self.referer = referer
      self.class.base_uri "#{account_name}.88pages.com"
    end

    def method_missing(form, *args)
      begin
        self.class.get("/api/forms/#{form.to_s.gsub('_', '-')}/entries.json?referer=#{referer}").parsed_response
      rescue
        rescue super(field, *args)
      end
    end
  end
end
