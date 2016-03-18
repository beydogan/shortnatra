require 'securerandom'
require 'ohm/contrib'

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
