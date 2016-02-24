require 'sinatra'
require 'redis'
require 'securerandom'
require 'ohm'
require 'ohm/contrib'
require 'sinatra/json'
require 'dotenv'
Dotenv.load

class ShortUrl < Ohm::Model
  include Ohm::DataTypes
  include Ohm::Callbacks

  attribute :shortcode
  attribute :url
  attribute :start_date, ->(t) {t && (t.is_a?(Time) ? t : Time.parse(t).utc.iso8601)}
  attribute :last_seen_date, ->(t) {t && (t.is_a?(Time) ? t : Time.parse(t).utc.iso8601)}
  attribute :redirect_count, Type::Integer
  index :shortcode

  def before_save
    self.start_date ||= Time.now.utc.iso8601
    self.shortcode ||= generate_shortcode
  end

  def hit!
    self.last_seen_date = Time.now.utc.iso8601
    self.redirect_count += 1
    self.save
  end

  private
    def generate_shortcode
      shortcode = SecureRandom.hex(3)
      while ShortUrl.find(shortcode: shortcode).first
        shortcode = SecureRandom.hex(3)
      end
      shortcode
    end
end

class ShortNatra < Sinatra::Base

  configure do
    Ohm.redis = Redic.new("redis://#{ENV["REDIS_PORT_6379_TCP_ADDR"]}:#{ENV["REDIS_PORT_6379_TCP_PORT"]}")
    enable :logging
    file = File.new("#{settings.root}/#{settings.environment}.log", 'a+')
    file.sync = true
    use Rack::CommonLogger, file
  end

  helpers do
    def shortcode_valid?(shortcode)
      shortcode.match(/^[0-9a-zA-Z_]{4,}$/)
    end

    def url_valid?(url)
      url
    end
  end

  post '/shorten' do
    content_type :json

    if url_valid? params[:url]
      if params[:shortcode]
        if shortcode_valid? params[:shortcode]
          if ShortUrl.find(shortcode: params[:shortcode]).first
            status 409
            {status: "error", message: "The the desired shortcode is already in use. **Shortcodes are case-sensitive**."}.to_json
          else
            status 201
            url = ShortUrl.create(shortcode: params[:shortcode], url: params[:url])
            {shortcode: url.shortcode}.to_json
          end
        else
          status 422
          {status: "error", message: "The shortcode fails to meet the following regexp: ```^[0-9a-zA-Z_]{4,}$```."}.to_json
        end
      else
        status 201
        url = ShortUrl.create(url: params[:url])
        {shortcode: url.shortcode}.to_json
      end
    else
      status 400
      {status: "error", message: "```url``` is not present"}.to_json
    end
  end

  get '/:shortcode/stats' do
    content_type :json
    url = ShortUrl.find(shortcode: params[:shortcode]).first

    if url.nil?
      status 404
      {status: "error", message: "The shortcode cannot be found in the system"}.to_json
    else
      {
        "startDate": url.start_date,
        "lastSeenDate": url.last_seen_date,
        "redirectCount": url.redirect_count
      }.to_json
    end
  end

  get '/:shortcode' do
    url = ShortUrl.find(shortcode: params[:shortcode]).first

    if url.nil?
      content_type :json
      status 404
      {status: "error", message: "The shortcode cannot be found in the system"}.to_json
    else
      url.hit!
      status 302
      redirect url.url
    end
  end

end
