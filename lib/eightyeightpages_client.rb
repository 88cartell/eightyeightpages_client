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
      @records ||= self.class.get(self.url).parsed_response.map { |record| ReadStruct.new(record) }
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
end

class ReadStruct
  attr_accessor :attributes

  def initialize(attributes)
    self.attributes = attributes
  end

  def [](field)
    val = self.attributes[field]
    if field.is_a?(Symbol) and val.nil?
      val = self.attributes[field.to_s]
    elsif field.is_a?(String) and val.nil?
      val = self.attributes[field.to_sym]
    end
    val
  end

  def key_ends_with?(key, suffix)
    suffix = suffix.to_s
    key[-suffix.length, suffix.length] == suffix
  end

  def method_missing(field, *args)
    begin
      if key_ends_with?(field.to_s, '=')
        self.attributes[field] = args.first
      elsif (self.attributes.key?(field) || self.attributes.key?(field.to_s))
        val = self.attributes[field] || self.attributes[field.to_s]
        if val.is_a?(Hash)
          ReadStruct.new val
        elsif val.is_a?(Array)
          val.map do |elem|
            if elem.is_a?(Hash)
              ReadStruct.new elem
            else
              elem
            end
          end
        else
          val
        end
      else
        nil # Return nil like a normal hash would.
      end
    rescue => e
      super(field, *args)
    end
  end
end
