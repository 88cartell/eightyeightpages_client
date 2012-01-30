require 'eightyeightpages_client/version'
require 'eightyeightpages_client/keyed_hash'
require 'eightyeightpages_client/hash_with_indifferent_access'
require 'httparty'
require 'delegate'

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
      @records ||= self.class.get(self.url).parsed_response.map { |record| SuperHash.new(record) }
    end

    def where(hash)
      @records = nil
      hash.each do |key, value|
        self.url += "&where[#{key}]=#{value}"
      end
      self
    end

    def any_of(*array)
      @records = nil
      array.each do |match|
        match.each do |key, value|
          self.url += "&any_of[#{key}][]=#{value}"
        end
      end
      self
    end

    def any_in(hash)
      @records = nil
      hash.each do |key, value|
        value.each do |v|
          self.url += "&any_in[#{key}][]=#{v}"
        end
      end
      self
    end

    def order_by(hash)
      @records = nil
      hash.each do |key, value|
        value = 'asc' if value != 'asc' and value != 'desc'
        self.url += "&order_by[#{key}]=#{value}"
      end
      self
    end

    def skip(amount)
      @records = nil
      self.url += "&skip=#{amount.to_i}"
      self
    end

    def limit(amount)
      @records = nil
      self.url += "&limit=#{amount.to_i}"
      self
    end

    def method_missing(method, *args)
      begin
        records.send(method, *args)
      rescue
        rescue super(field, *args)
      end
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
      begin
        Result.new(self.base_uri, "/api/forms/#{form.to_s.gsub('_', '-')}/entries.json?referer=#{referer}")
      rescue
        rescue super(field, *args)
      end
    end
  end

  class SuperHash < Delegator
    attr_accessor :attributes

    def initialize(attributes)
      self.attributes = EightyeightpagesClient::HashWithIndifferentAccess.new attributes
      self.coerce!
      self.define_key_methods!
    end

    def coerce!
      self.attributes.each do |key, value|
        case value
        when Hash
          self.attributes[key] = EightyeightpagesClient::SuperHash.new value
        when Array
          value.each_with_index do |array_value, index|
            value[index] = EightyeightpagesClient::SuperHash.new(array_value) if array_value.is_a?(Hash)
          end
        end
      end
    end

    def define_key_methods!
      self.attributes.each do |key, value|
        self.class.send(:define_method, key.to_sym) do
          self.attributes[key]
        end
      end
    end

    def __getobj__
      @attributes
    end

    def to_json
      @attributes.to_json
    end
  end
end


