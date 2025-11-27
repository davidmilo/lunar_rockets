require "rails_helper"

RSpec.describe ProcessNewRocketMessages do
  subject{ described_class }
  describe ".call" do
    let!(:rocket) { Rocket.create!(uuid: "193270a9-c9cf-404a-8f83-838e71d9ae67") }
    let(:build_rocket_launched_message) do
      ->(number) {
        rocket.rocket_messages.create!(
          number: number,
          type: "RocketMessages::RocketLaunched",
          message: {
            type: "Falcon-9",
            launchSpeed: 500,
            mission: "ARTEMIS"
          }
        )
      }
    end
    let(:build_rocket_speed_increased_message) do
      ->(number){
        rocket.rocket_messages.create!(
          number: number,
          type: "RocketMessages::RocketSpeedIncreased",
          message: { by: 100 }
        )
      }
    end
    let(:build_rocket_speed_decreased_message) do
      ->(number) {
        rocket.rocket_messages.create!(
          number: number,
          type: "RocketMessages::RocketSpeedDecreased",
          message: { by: 50 }
        )
      }
    end
    let(:build_rocket_mission_changed_message) do
      ->(number) {
        rocket.rocket_messages.create!(
          number: number,
          type: "RocketMessages::RocketMissionChanged",
          message: { newMission: "LUNAR-X" }
        )
      }
    end
    let(:build_rocket_exploaded_message) do
      ->(number) {
        rocket.rocket_messages.create!(
          number: number,
          type: "RocketMessages::RocketExploded",
          message: { reason: "Boom" }
        )
      }
    end

    context "launching rocket" do
      it "updates rocket attributes correctly" do
        build_rocket_launched_message.call(1)

        subject.call(rocket_id: rocket.id)

        expect(rocket.reload.attributes).to include(
          "rocket_type" => "Falcon-9",
          "speed" => 500,
          "mission" => "ARTEMIS"
        )
      end
    end

    context "increasing speed" do
      it "updates rocket attributes correctly" do
        build_rocket_launched_message.call(1)
        build_rocket_speed_increased_message.call(2)

        subject.call(rocket_id: rocket.id)

        expect(rocket.reload.attributes).to include(
          "status" => "launched",
          "rocket_type" => "Falcon-9",
          "speed" => 600,
          "mission" => "ARTEMIS"
        )
      end
    end

    context "decreasing speed" do
      it "updates rocket attributes correctly" do
        build_rocket_launched_message.call(1)
        build_rocket_speed_decreased_message.call(2)

        subject.call(rocket_id: rocket.id)

        expect(rocket.reload.attributes).to include(
          "status" => "launched",
          "rocket_type" => "Falcon-9",
          "speed" => 450,
          "mission" => "ARTEMIS"
        )
      end
    end

    context "changing mission" do
      it "updates rocket attributes correctly" do
        build_rocket_launched_message.call(1)
        build_rocket_mission_changed_message.call(2)

        subject.call(rocket_id: rocket.id)

        expect(rocket.reload.attributes).to include(
          "status" => "launched",
          "rocket_type" => "Falcon-9",
          "speed" => 500,
          "mission" => "LUNAR-X"
        )
      end
    end

    context "rocket exploding" do
      it "updates rocket attributes correctly" do
        build_rocket_launched_message.call(1)
        build_rocket_exploaded_message.call(2)

        subject.call(rocket_id: rocket.id)

        expect(rocket.reload.attributes).to include(
          "status" => "exploded",
          "rocket_type" => "Falcon-9",
          "speed" => 500,
          "mission" => "ARTEMIS",
          "accident" => "Boom"
        )
      end
    end

    context "when messages are missing" do
      it "doesn't execute subsequent updates" do
        build_rocket_launched_message.call(1)
        build_rocket_speed_increased_message.call(3)

        subject.call(rocket_id: rocket.id)

        expect(rocket.reload.attributes).to include(
          "status" => "launched",
          "rocket_type" => "Falcon-9",
          "speed" => 500,
          "mission" => "ARTEMIS",
          "accident" => nil
        )
      end
    end

    context "chain with all message types" do
      it "updates rocket attributes correctly" do
        build_rocket_launched_message.call(1)
        build_rocket_speed_increased_message.call(2)
        build_rocket_speed_decreased_message.call(3)
        build_rocket_mission_changed_message.call(4)
        build_rocket_exploaded_message.call(5)

        subject.call(rocket_id: rocket.id)

        expect(rocket.reload.attributes).to include(
          "status" => "exploded",
          "rocket_type" => "Falcon-9",
          "speed" => 550,
          "mission" => "LUNAR-X",
          "accident" => "Boom"
        )
      end
    end
  end
end
