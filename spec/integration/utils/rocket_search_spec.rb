# spec/services/rocket_search_spec.rb
require "rails_helper"

RSpec.describe RocketSearch do
  let!(:rocket1) do
    Rocket.create!(
      speed: 5,
      status: "exploded",
      mission: "MISSION_A",
      rocket_type: "Falcon"
    )
  end

  let!(:rocket2) do
    Rocket.create!(
      speed: 15,
      status: "launched",
      mission: "MISSION_B",
      rocket_type: "Starship"
    )
  end

  let!(:rocket3) do
    Rocket.create!(
      speed: 30,
      status: "launched",
      mission: "MISSION_A",
      rocket_type: "Falcon"
    )
  end

  let(:base_scope) { Rocket.all }
  let(:filters) { {} }

  subject { described_class.new(filters: filters) }

  let(:paginator) { instance_double(Paginator) }

  before do
    allow(Paginator).to receive(:new).and_return(paginator)
    allow(paginator).to receive(:paginate) do |scope, page:, per_page:|
      scope
    end
  end

  describe "#call" do
    context "without any filters" do
      it "returns all rockets ordered by id desc by default" do
        result = subject.call(base_scope)

        expect(result).to eq([rocket3, rocket2, rocket1].sort_by(&:id).reverse)
      end
    end

    context "with speed_above filter" do
      let(:filters) { { speed_above: 10 } }

      it "returns rockets with speed greater than the threshold" do
        result = subject.call(base_scope)

        expect(result).to match_array([rocket2, rocket3])
      end
    end

    context "with speed_under filter" do
      let(:filters) { { speed_under: 20 } }

      it "returns rockets with speed less than the threshold" do
        result = subject.call(base_scope)

        expect(result).to match_array([rocket1, rocket2])
      end
    end

    context "with status filter" do
      let(:filters) { { status: "launched" } }

      it "returns only rockets with that status" do
        result = subject.call(base_scope)

        expect(result).to match_array([rocket2, rocket3])
      end
    end

    context "with mission filter" do
      let(:filters) { { mission: "MISSION_A" } }

      it "returns only rockets with that mission" do
        result = subject.call(base_scope)

        expect(result).to match_array([rocket1, rocket3])
      end
    end

    context "with rocket_type filter" do
      let(:filters) { { rocket_type: "Falcon" } }

      it "returns only rockets of that type" do
        result = subject.call(base_scope)

        expect(result).to match_array([rocket1, rocket3])
      end
    end

    context "with multiple filters combined" do
      let(:filters) do
        {
          speed_above: 10,
          status: "launched",
          mission: "MISSION_A",
          rocket_type: "Falcon"
        }
      end

      it "applies all filters" do
        result = subject.call(base_scope)

        expect(result).to match_array([rocket3])
      end
    end

    context "with sort by speed_asc" do
      let(:filters) { { sort: "speed_asc" } }

      it "orders by speed ascending" do
        result = subject.call(base_scope)

        expect(result.map(&:speed)).to eq([5, 15, 30])
      end
    end

    context "with sort by speed_desc" do
      let(:filters) { { sort: "speed_desc" } }

      it "orders by speed descending" do
        result = subject.call(base_scope)

        expect(result.map(&:speed)).to eq([30, 15, 5])
      end
    end
  end
end
