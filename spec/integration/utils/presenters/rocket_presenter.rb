require "rails_helper"

RSpec.describe RocketPresenter do
  subject { described_class }

  let(:rocket) do
    Rocket.create!(
      uuid: SecureRandom.uuid,
      status: "active",
      rocket_type: "Falcon-9",
      speed: 5000,
      mission: "ARTEMIS",
      accident: nil,
      last_processed_message_number: 1,
      last_processed_message_at: Time.current
    )
  end

  let!(:old_message) do
    rocket.rocket_messages.create!(
      number: 1,
      message: {},
      time: Time.current,
      type: "RocketMessages::RocketLaunched"
    )
  end

  let!(:new_message_1) do
    rocket.rocket_messages.create!(
      number: 2,
      message: {},
      time: Time.current,
      type: "RocketMessages::RocketSpeedIncreased"
    )
  end

  let!(:new_message_2) do
    rocket.rocket_messages.create!(
      number: 3,
      message: {},
      time: Time.current,
      type: "RocketMessages::RocketSpeedDecreased"
    )
  end

  describe "#as_json" do
    context "without unprocessed_message_count option" do
      it "returns the basic rocket fields" do
        json = subject.new(rocket: rocket).as_json

        expect(json).to include(
          id: rocket.id,
          uuid: rocket.uuid,
          status: rocket.status,
          rocket_type: rocket.rocket_type,
          speed: rocket.speed,
          mission: rocket.mission,
          accident: rocket.accident,
          last_processed_message_number: 1,
          last_processed_message_at: rocket.last_processed_message_at
        )
      end

      it "does not include unprocessed_message_count" do
        json = subject.new(rocket: rocket).as_json
        expect(json).not_to have_key(:unprocessed_message_count)
      end
    end

    context "with show_unprocessed_message_count option enabled" do
      subject(:json) { described_class.new(rocket: rocket, options: { show_unprocessed_message_count: true }).as_json }

      it "includes unprocessed_message_count" do
        json = subject.new(rocket: rocket, options: { show_unprocessed_message_count: true }).as_json
        expect(json[:unprocessed_message_count]).to eq(2)
      end
    end
  end
end
