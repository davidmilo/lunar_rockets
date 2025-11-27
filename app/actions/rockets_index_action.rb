class RocketsIndexAction
  def initialize(filters:)
    @filters = filters
  end

  def call
    paginated_result = RocketSearch.new(filters: filters).call(Rocket.all)
    {
      pagination: paginated_result.slice(:total_count, :total_pages, :current_page, :per_page),
      rockets: paginated_result[:records].map do |rocket|
        RocketPresenter.new(rocket:).as_json
      end
    }
  end

  private

  attr_reader :filters
end
