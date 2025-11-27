require "rails_helper"

RSpec.describe Paginator do
  subject do
     described_class.new(
      default_per_page:,
      min_per_page:,
      max_per_page:,
      default_page:
    )
  end

  let(:paginated_scope) { double("result") }
  let(:limited_scope) { double(offset: paginated_scope) }
  let(:scope) { double(count: count, limit: limited_scope) }

  let(:default_per_page) { 25 }
  let(:min_per_page) { 20 }
  let(:max_per_page) { 30 }
  let(:default_page) { 1 }
  let(:count) { 55 }

  context "when called without page per_page" do
    let(:page) { nil }
    let(:per_page) { nil }

    it "returns correct pagination result using default values" do
      result = subject.paginate(scope, page: page, per_page: per_page)

      expect(result).to eq(
        {
          total_count: 55,
          total_pages: 3,
          current_page: 1,
          per_page: 25,
          records: paginated_scope
        }
      )
    end

    it "paginates scope with expected values" do
      expect(scope).to receive(:limit).with(25)
      expect(limited_scope).to receive(:offset).with(0)

      subject.paginate(scope, page: page, per_page: per_page)
    end
  end

  context "when called with higher per_page than allowed" do
    let(:page) { nil }
    let(:per_page) { 40 }

    it "returns correct pagination result using max_per_page" do
      result = subject.paginate(scope, page: page, per_page: per_page)

      expect(result).to eq(
        {
          total_count: 55,
          total_pages: 2,
          current_page: 1,
          per_page: 30,
          records: paginated_scope
        }
      )
    end

    it "paginates scope with expected values" do
      expect(scope).to receive(:limit).with(30)
      expect(limited_scope).to receive(:offset).with(0)

      subject.paginate(scope, page: page, per_page: per_page)
    end
  end

  context "when called with lower per_page than allowed" do
    let(:page) { nil }
    let(:per_page) { 10 }

    it "returns correct pagination result using min_per_page" do
      result = subject.paginate(scope, page: page, per_page: per_page)

      expect(result).to eq(
        {
          total_count: 55,
          total_pages: 3,
          current_page: 1,
          per_page: 20,
          records: paginated_scope
        }
      )
    end

    it "paginates scope with expected values" do
      expect(scope).to receive(:limit).with(20)
      expect(limited_scope).to receive(:offset).with(0)

      subject.paginate(scope, page: page, per_page: per_page)
    end
  end

  context "when called with negative page" do
    let(:page) { -2 }
    let(:per_page) { nil }

    it "returns correct pagination result using page=1" do
      result = subject.paginate(scope, page: page, per_page: per_page)

      expect(result).to eq(
        {
          total_count: 55,
          total_pages: 3,
          current_page: 1,
          per_page: 25,
          records: paginated_scope
        }
      )
    end

    it "paginates scope with expected values" do
      expect(scope).to receive(:limit).with(25)
      expect(limited_scope).to receive(:offset).with(0)

      subject.paginate(scope, page: page, per_page: per_page)
    end
  end

  context "when called with page higher than total_pages" do
    let(:page) { 5 }
    let(:per_page) { nil }

    it "returns correct pagination result using highest possible page" do
      result = subject.paginate(scope, page: page, per_page: per_page)

      expect(result).to eq(
        {
          total_count: 55,
          total_pages: 3,
          current_page: 3,
          per_page: 25,
          records: paginated_scope
        }
      )
    end

    it "paginates scope with expected values" do
      expect(scope).to receive(:limit).with(25)
      expect(limited_scope).to receive(:offset).with(50)

      subject.paginate(scope, page: page, per_page: per_page)
    end
  end

  context "when called with string values" do
    let(:page) { "5" }
    let(:per_page) { "25" }

    it "fails as expected" do
      expect {
        subject.paginate(scope, page: page, per_page: per_page)
      }.to raise_error(ArgumentError)
    end
  end
end
