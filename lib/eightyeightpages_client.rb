require 'eightyeightpages_client/version'
require 'httparty'

module EightyeightpagesClient
  class Result
    include HTTParty
    include Enumerable

    attr_accessor :url

    def initialize(base_uri, url)
      self.url = url
      self.class.base_uri base_uri
    end

    def each
      records.each do |record|
        yield record
      end
    end

    def records
      @records ||= self.class.get(self.url).parsed_response
    end

    def length
      records.length
    end

    def where(hash)
      hash.each do |key, value|
        self.url += "&where[#{key}]=#{value}"
      end
      self
    end

    def any_of(*array)
      array.each do |match|
        match.each do |key, value|
          self.url += "&any_of[#{key}][]=#{value}"
        end
      end
      self
    end

    def any_in(hash)
      hash.each do |key, value|
        value.each do |v|
          self.url += "&any_in[#{key}][]=#{v}"
        end
      end
      self
    end

    def order_by(hash)
      hash.each do |key, value|
        value = 'asc' if value != 'asc' and value != 'desc'
        self.url += "&order_by[#{key}]=#{value}"
      end
      self
    end

    def skip(amount)
      self.url += "&skip=#{amount.to_i}"
      self
    end

    def limit(amount)
      self.url += "&limit=#{amount.to_i}"
      self
    end
  end

  class Query
    attr_accessor :account_name, :referer, :base_uri

    def initialize(account_name, referer)
      self.account_name = account_name
      self.referer = referer
      self.base_uri = "#{account_name}.88pages.com"
    end

    def method_missing(form, *args)
      #begin
        Result.new(self.base_uri, "/api/forms/#{form.to_s.gsub('_', '-')}/entries.json?referer=#{referer}")
      #rescue
      #  rescue super(field, *args)
      #end
    end
  end
end
