require "rails_helper"

RSpec.describe RocketMessagesController, type: :request do
  describe "#show" do
    context "with minimum valid parameters" do
      let!(:rocket) { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }

      it "returns http success" do
        get "/rockets/#{rocket.id}"
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "#index" do
    context "with minimum valid parameters" do
      let!(:rocket) { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }

      it "returns http success" do
        get "/rockets"
        expect(response).to have_http_status(:success)
      end
    end
  end
end
