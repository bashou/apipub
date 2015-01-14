require 'spec_helper'

describe API::Root do
  include Rack::Test::Methods
  include ApiHelpers


  def app
    API::Root
  end

  describe "GET /api/version" do
    it "returns version of api" do
      get api("/api/version")
      expect(last_response.status).to eq(200)
      expect(json_response).to be_kind_of(Hash)
      expect(json_response).to have_key('version')
    end
  end
  describe 'Swagger Documentation'do
    it "swagger documentation" do
      get api("/doc.json")
      expect(last_response.status).to eq(200)
      expect(json_response).to be_kind_of(Hash)
      expect(json_response["apiVersion"]).to eq('v1')
      expect(json_response["swaggerVersion"]).to eq('1.2')
    end
  end
end