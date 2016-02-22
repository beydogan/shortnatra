require 'sinatra'
require 'redis'
require 'securerandom'
require 'ohm'
require 'ohm/contrib'
require 'sinatra/json'

class ShortUrl < Ohm::Model
  
end

class ShortNatra < Sinatra::Base

  configure do
    Ohm.redis = Redic.new("redis://127.0.0.1:6379")
  end

end
