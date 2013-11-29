require 'redis'

config = YAML.load( File.open( Rails.root.join("config/redis.yml") ) ).symbolize_keys
REDIS_CONFIG = config[:default].symbolize_keys
if config[Rails.env.to_sym]
  REDIS_CONFIG.merge!(config[Rails.env.to_sym].symbolize_keys)
end

# if @configurationfilename given, find out what the password is
if REDIS_CONFIG.has_key?(:password)
  if REDIS_CONFIG[:password].empty?
    REDIS_CONFIG.delete(:password)
  elsif REDIS_CONFIG[:password][0]=="@"
    redisconf = REDIS_CONFIG[:password]
    redisconf.slice!(0)
    matcher = File.open(redisconf,"r") { |f| f.read.match(/^ *requirepass +([[:word:]]*) *$/) }
    if matcher.nil?
      REDIS_CONFIG.delete(:password)
    else
      REDIS_CONFIG[:password] = matcher[1]
    end
  end
end

$redis = Redis.new(REDIS_CONFIG)
# To clear out the db before each test
$redis.flushdb if Rails.env == "test"

$qless = Qless::Client.new(REDIS_CONFIG.merge(:redis => $redis))
$qless.config['heartbeat'] = 1800
# To use Redis::Objects
#require 'redis/objects'
#Redis::Objects.redis = $redis
 

