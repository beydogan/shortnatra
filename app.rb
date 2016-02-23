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

  def hit!
    self.last_seen_date = Time.now
    self.redirect_count += 1
    self.save
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

  helpers do
    def code_valid?(code)
      code.match(/^[0-9a-zA-Z_]{4,}$/)
    end

    def url_valid?(url)
      url
    end
  end

  post '/shorten' do
    content_type :json

    if url_valid? params[:url]
      if params[:code]
        if code_valid? params[:code]
          if ShortUrl.find(code: params[:code]).first
            status 409
            {status: "error", message: "The the desired shortcode is already in use. **Shortcodes are case-sensitive**."}.to_json
          else
            status 201
            url = ShortUrl.new(code: params[:code], url: params[:url])
            url.save
            {shortcode: url.code}.to_json
          end
        else
          status 422
          {status: "error", message: "The shortcode fails to meet the following regexp: ```^[0-9a-zA-Z_]{4,}$```."}.to_json
        end
      else
        status 201
        url = ShortUrl.new(url: params[:url])
        url.save
        {shortcode: url.code}.to_json
      end
    else
      status 400
      {status: "error", message: "```url``` is not present"}.to_json
    end
  end

end
