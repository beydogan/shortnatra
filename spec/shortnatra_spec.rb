require "spec_helper"

RSpec.describe ShortNatra do
  def app
    ShortNatra
  end

  describe "POST /shorten" do
    context "with shortcode param" do
      it "returns 201 and creates ShortUrl if shortcode and url is valid" do
        post "/shorten", {shortcode: "code1", url: "http://www.google.com"}
        expect(last_response.status).to eq 201
        url = ShortUrl.find(shortcode: "code1").first
        expect(url).not_to eq(nil)
        expect(url.url).to eq("http://www.google.com")
      end

      it "returns 409 if shortcode is already exists" do
        ShortUrl.new(shortcode: "code1", url: "http://www.google.com").save
        post "/shorten", {shortcode: "code1", url: "http://www.google.com"}
        expect(last_response.status).to eq 409
      end

      it "returns 422 if shortcode is invalid regex" do
        post "/shorten", {shortcode: "c-x", url: "http://www.google.com"}
        expect(last_response.status).to eq 422
        url = ShortUrl.find(shortcode: "c-x").first
        expect(url).to eq(nil)
      end

      it "returns 400 if url is missing" do
        post "/shorten", {shortcode: "code1"}
        expect(last_response.status).to eq 400
      end
    end

    context "without shortcode param" do
      it "returns 201 and creates ShortUrl if url is present" do
        post "/shorten", {url: "http://www.google.com"}
        expect(last_response.status).to eq 201
        shortcode = JSON.parse(last_response.body)["shortcode"]
        url = ShortUrl.find(shortcode: shortcode).first
        expect(url).not_to eq(nil)
        expect(url.url).to eq("http://www.google.com")
      end

      it "returns 400 if url is missing" do
        post "/shorten", {}
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "GET /:shortcode" do
    context "with valid shortcode" do
      let!(:url){ ShortUrl.create(url: "http://www.google.com")}

      it "returns 302 and redirect" do
        get "/#{url.shortcode}"
        expect(last_response.status).to eq 302
        expect(last_response).to be_redirect
        follow_redirect!
        expect(last_request.url).to eq "http://www.google.com/"
      end

      it "updates url stats" do
        Timecop.freeze(Time.now.utc.iso8601)
        get "/#{url.shortcode}"
        saved_url = ShortUrl.find(shortcode: url.shortcode).first
        expect(saved_url.redirect_count).to eq 1
        expect(saved_url.last_seen_date).to eq Time.now.utc.iso8601 # using #to_s to workaround nanosecond comparison
      end
    end

    context "with invalid shortcode" do
      it "returns 404 not found" do
        get "/randomcode"
        expect(last_response.status).to eq 404
        expect(last_response.body).to include "The shortcode cannot be found in the system"
      end
    end
  end

  describe "GET /:shortcode/stats" do
    context "with valid shortcode" do
      it "returns shortcode stats" do
        pending "TODO"
      end
    end
    context "with invalid shortcode" do
      it "returns 404 not found" do
        pending "TODO"
      end
    end
  end
end
