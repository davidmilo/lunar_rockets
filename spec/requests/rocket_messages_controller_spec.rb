require "rails_helper"

RSpec.describe RocketMessagesController, type: :request do
  describe "#index" do
    context "with minimum valid parameters" do
      let!(:rocket) { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }
      let!(:rocket_message) { RocketMessage.create!(number: 1, message: {}, rocket: rocket) }

      it "returns http success" do
        get "/rockets/#{rocket.id}/rocket_messages", params: { page: 1, per_page: 10 }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
