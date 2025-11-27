require "rails_helper"

RSpec.describe MessagesController, type: :request do
  describe "#create" do
    context "message type: RocketLaunched" do
      context "with valid parameters" do
        it "returns http success" do
          expect(ProcessNewRocketMessagesJob).to receive(:perform_later)

          post "/messages", params: {
            metadata: {
              channel: "193270a9-c9cf-404a-8f83-838e71d9ae67",
              messageNumber: 1,
              messageTime: "2022-02-02T19:39:05.86337+01:00",
              messageType: "RocketLaunched"
            },
            message: {
                type: "Falcon-9",
                launchSpeed: 500,
                mission: "ARTEMIS"
            }
          }

          expect(response).to have_http_status(:success)
        end
      end
    end

    context "message type: RocketSpeedIncreased" do
      context "with valid parameters" do
        before { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }
        it "returns http success" do
          expect(ProcessNewRocketMessagesJob).to receive(:perform_later).with(rocket_id: Rocket.last.id)

          post "/messages", params: {
            metadata: {
              channel: "193270a9-c9cf-404a-8f83-838e71d9ae67",
              messageNumber: 1,
              messageTime: "2022-02-02T19:39:05.86337+01:00",
              messageType: "RocketSpeedIncreased"
            },
            message: {
              by: 100
            }
          }

          expect(response).to have_http_status(:success)
        end
      end
    end

    context "message type: RocketSpeedDecreased" do
      context "with valid parameters" do
        before { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }
        it "returns http success" do
          expect(ProcessNewRocketMessagesJob).to receive(:perform_later).with(rocket_id: Rocket.last.id)

          post "/messages", params: {
            metadata: {
              channel: "193270a9-c9cf-404a-8f83-838e71d9ae67",
              messageNumber: 1,
              messageTime: "2022-02-02T19:39:05.86337+01:00",
              messageType: "RocketSpeedDecreased"
            },
            message: {
              by: 100
            }
          }

          expect(response).to have_http_status(:success)
        end
      end
    end

    context "message type: RocketExploded" do
      context "with valid parameters" do
        before { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }
        it "returns http success" do
          expect(ProcessNewRocketMessagesJob).to receive(:perform_later).with(rocket_id: Rocket.last.id)

          post "/messages", params: {
            metadata: {
              channel: "193270a9-c9cf-404a-8f83-838e71d9ae67",
              messageNumber: 1,
              messageTime: "2022-02-02T19:39:05.86337+01:00",
              messageType: "RocketExploded"
            },
            message: {
              reason: "BOOOM"
            }
          }

          expect(response).to have_http_status(:success)
        end
      end
    end

    context "message type: RocketMissionChanged" do
      context "with valid parameters" do
        before { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }
        it "returns http success" do
          expect(ProcessNewRocketMessagesJob).to receive(:perform_later).with(rocket_id: Rocket.last.id)

          post "/messages", params: {
            metadata: {
              channel: "193270a9-c9cf-404a-8f83-838e71d9ae67",
              messageNumber: 1,
              messageTime: "2022-02-02T19:39:05.86337+01:00",
              messageType: "RocketMissionChanged"
            },
            message: {
              newMission: "Artemis II"
            }
          }

          expect(response).to have_http_status(:success)
        end
      end
    end
  end
end
