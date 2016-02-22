require "spec_helper"

RSpec.describe ShortNatra do
  def app
    ShortNatra
  end

  describe "POST /shorten" do
    context "with code param" do
      it "returns 201 created if code is valid" do

      end

      it "returns 409 if code is already exists" do

      end

      it "returns 402 if code is invalid regex" do

      end

      it "returns 400 if url is missing" do

      end
    end

    context "without code param" do
      it "returns 201 if url is present" do

      end

      it "returns 400 if url is missing" do

      end
    end
  end

  describe "GET /:shortcode" do
    context "with valid shortcode" do
      it "returns 302 redirect" do

      end
    end
    context "with invalid shortcode" do
      it "returns 404 not found" do

      end
    end
  end

  describe "GET /:shortcode/stats" do
    context "with valid shortcode" do
      it "returns shortcode stats" do

      end
    end
    context "with invalid shortcode" do
      it "returns 404 not found" do

      end
    end
  end
end
