require 'sinatra'
require 'redis'
require 'securerandom'
require 'ohm'
require 'ohm/contrib'
require 'sinatra/json'

class ShortUrl < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :code
  attribute :url
  attribute :start_date, Type::Time
  attribute :last_seen_date, Type::Time
  attribute :redirect_count, Type::Integer
  index :code


  def before_save
    self.start_date = Time.now
    self.code ||= generate_code
  end

  private
    def generate_code
      code = SecureRandom.hex(6)
      while ShortUrl.find(code: code).first
        code = SecureRandom.hex(6)
      end
      code
    end

end

class ShortNatra < Sinatra::Base

  configure do
    Ohm.redis = Redic.new("redis://127.0.0.1:6379")
  end

end
