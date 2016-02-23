require "spec_helper"

RSpec.describe ShortNatra do
  def app
    ShortNatra
  end

  describe "POST /shorten" do
    context "with code param" do
      it "returns 201 and creates ShortUrl if code and url is valid" do
        post "/shorten", {code: "code1", url: "http://www.google.com"}
        expect(last_response.status).to eq 201
        url = ShortUrl.find(code: "code1").first
        expect(url).not_to eq(nil)
        expect(url.url).to eq("http://www.google.com")
      end

      it "returns 409 if code is already exists" do
        ShortUrl.new(code: "code1", url: "http://www.google.com").save
        post "/shorten", {code: "code1", url: "http://www.google.com"}
        expect(last_response.status).to eq 409
      end

      it "returns 402 if code is invalid regex" do
        post "/shorten", {code: "c-x", url: "http://www.google.com"}
        expect(last_response.status).to eq 402
        url = ShortUrl.find(code: "c-x").first
        expect(url).to eq(nil)
      end

      it "returns 400 if url is missing" do
        post "/shorten", {code: "c-x"}
        expect(last_response.status).to eq 400
      end

      it "returns 400 if url is invalid" do
        post "/shorten", {code: "c-x", url: "invalidurl"}
        expect(last_response.status).to eq 400
      end
    end

    context "without code param" do
      it "returns 201 and creates ShortUrl if url is present" do
        post "/shorten", {url: "http://www.google.com"}
        expect(last_response.status).to eq 201
        code = JSON.parse(last_response.body)[:shortcode]
        url = ShortUrl.find(code: code).first
        expect(url).not_to eq(nil)
        expect(url.url).to eq("http://www.google.com")
      end

      it "returns 400 if url is missing" do
        post "/shorten", {}
        expect(last_response.status).to eq 400
      end

      it "returns 400 if url is invalid" do
        post "/shorten", {url: "invalidurl"}
        expect(last_response.status).to eq 400
      end
    end
  end

  describe "GET /:shortcode" do
    context "with valid shortcode" do
      it "returns 302 redirect" do
        pending "TODO"
      end
    end
    context "with invalid shortcode" do
      it "returns 404 not found" do
        pending "TODO"
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
