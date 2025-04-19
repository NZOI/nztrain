class Enumeration
  # Usage:
  # Construct the enumeration:
  #
  #   COLOUR = Enumeration.new 0 => :red, 1 => :blue
  #
  # or
  #
  #   COLOUR = Enumeration.new red: 0, blue: 1
  #
  # Access the enumeration:
  #
  #   COLOUR[:red] # 0
  #   COLOUR[1] # :blue
  #

  def initialize(enum_hash)
    @enum = {}
    @description = {}
    @entries = {}
    enum_hash.each do |key, value|
      if value.instance_of?(Array)
        description = value[1]
        value = value[0]
        @description[key] = description
        @description[value] = description
      end
      @enum[key] = value
      @enum[value] = key
      if value.class != Integer
        @entries[key] = value
      else
        @entries[value] = key
      end
    end
  end

  def [](value)
    value = value.to_sym if value.instance_of?(String)
    @enum[value]
  end

  def description(value)
    @description[value]
  end

  def to_i(value)
    value.is_a?(Integer) ? value : self[value]
  end

  attr_reader :entries

  delegate :each, :each_key, :each_value, to: :@entries
end
