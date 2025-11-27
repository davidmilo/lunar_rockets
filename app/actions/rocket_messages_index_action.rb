class RocketMessagesIndexAction
  def initialize(rocket_id:, filters:)
    @rocket_id = rocket_id
    @filters = filters
  end

  def call
    paginated_result = rocket_messages

    {
      rocket: RocketPresenter.new(rocket:, options: { show_unprocessed_events_count: true }).as_json,
      pagination: paginated_result.slice(:total_count, :total_pages, :current_page, :per_page),
      rocket_messages: paginated_result[:records].map do |message|
        {
          id: message.id,
          type: message.type,
          number: message.number,
          message: message.message,
          created_at: message.created_at,
          updated_at: message.updated_at
        }
      end
    }
  end

  private

  attr_reader :rocket_id, :filters

  def rocket
    @rocket ||= Rocket.find(rocket_id)
  end

  def rocket_messages
    Paginator.new(
      default_page: 1,
      default_per_page: 20,
      min_per_page: 20,
      max_per_page: 100
    ).paginate(
      rocket.rocket_messages.order(:number),
      page: filters[:page],
      per_page: filters[:per_page]
    )
  end
end
