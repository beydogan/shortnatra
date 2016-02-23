require "spec_helper"

RSpec.describe ShortUrl, type: :model do
  it do
    expect(subject.class.attributes).to include(:code)
    expect(subject.class.attributes).to include(:url)
    expect(subject.class.attributes).to include(:start_date)
    expect(subject.class.attributes).to include(:last_seen_date)
    expect(subject.class.attributes).to include(:redirect_count)
  end

  describe "code" do
    it "generates a code if its nil" do
      url = ShortUrl.new
      url.save
      expect(url.code).not_to eq nil
    end

    it "generates unique code" do
      allow(SecureRandom).to receive(:hex).and_return('code1', 'code1', 'code3', 'code4')

      ShortUrl.create(code: "code1")
      url = ShortUrl.create
      expect(url.code).to eq "code3"
    end
  end

  it "sets start_date before save" do
    url = ShortUrl.new
    url.save
    expect(url.start_date).not_to eq nil
  end
end
