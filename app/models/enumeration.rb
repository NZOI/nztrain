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
    @enum = Hash.new
    @description = Hash.new
    @entries = Hash.new
    enum_hash.each do |key,value|
      if value.class == Array
        description = value[1]
        value = value[0]
        @description[key] = description
        @description[value] = description
      end
      @enum[key] = value
      @enum[value] = key
      if value.class != Fixnum
        @entries[key] = value
      else
        @entries[value] = key
      end
    end
  end

  def [](value)
    value = value.to_sym if value.class == String
    @enum[value]
  end

  def description(value)
    @description[value]
  end

  def to_i(value)
    value.is_a?(Integer) ? value : self[value]
  end

  def entries
    @entries
  end

  delegate :each, :each_key, :each_value, to: :@entries
end
