require 'eightyeightpages_client/version'
require 'httparty'
require 'map'

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


class Object
  # The hidden singleton lurks behind everyone
  def metaclass; class << self; self; end; end
  alias_method :singleton_class, :metaclass

  def meta_eval(&blk)
    metaclass.instance_eval &blk
  end

  def meta_class_eval(code=nil, &blk)
    if code.nil?
      metaclass.class_eval &blk
    else
      metaclass.class_eval code, &blk
    end
  end

  # Adds methods to a metaclass
  def meta_def name, &blk
    meta_eval { define_method name, &blk }
  end

  # Defines an instance method within a class
  def class_def name, &blk
    class_eval { define_method name, &blk }
  end
end

class ReadStruct
  attr_accessor :attributes

  def initialize(attributes)
    self.attributes = attributes
  end

  def [](field)
    val = @attributes[field]
    if field.is_a?(Symbol) and val.nil?
      val = @attributes[field.to_s]
    elsif field.is_a?(String) and val.nil?
      val = @attributes[field.to_sym]
    end
    val
  end

  def method_missing(field, *args)
    begin
      if field.to_s.ends_with?('=')
        @attributes[field] = args.first
      elsif @attributes.key?(field) or @attributes.key?(field.to_s)
        val = @attributes[field]
        if val.is_a?(Hash)
          ReadStruct.new(attributes)
        else
          val
        end
      else
        nil # Return nil like a normal hash would.
      end
    rescue
      rescue super(field, *args)
    end
  end
end
