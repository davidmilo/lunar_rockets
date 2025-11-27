class RocketSearch
  DEFAULT_PER_PAGE = 20
  MIN_PER_PAGE = 10
  MAX_PER_PAGE = 25
  DEFAULT_PAGE = 1

  def initialize(filters:)
    @filters = filters
  end

  def call(scope)
    scope = apply_filters(scope)
    scope = apply_sorting(scope)

    apply_pagination(scope)
  end

  private

  attr_reader :filters

  def apply_filters(scope)
    if filters[:speed_above].present? && filters[:speed_above] > 0
      scope = scope.where("speed > ?", filters[:speed_above])
    end

    if filters[:speed_under].present? && filters[:speed_under] > 0
      scope = scope.where("speed < ?", filters[:speed_under])
    end

    if filters[:status].present?
      scope = scope.where(status: filters[:status])
    end

    if filters[:mission].present?
      scope = scope.where(mission: filters[:mission])
    end

    if filters[:rocket_type].present?
      scope = scope.where(rocket_type: filters[:rocket_type])
    end

    scope
  end

  def apply_sorting(scope)
    case filters[:sort]
    when "speed_asc"
      scope = scope.order(speed: :asc)
    when "speed_desc"
      scope = scope.order(speed: :desc)
    else
      scope = scope.order(id: :desc)
    end

    scope
  end

  def apply_pagination(scope)
   Paginator.new(
      default_per_page: DEFAULT_PER_PAGE,
      min_per_page: MIN_PER_PAGE,
      max_per_page: MAX_PER_PAGE,
      default_page: DEFAULT_PAGE
    ).paginate(
      scope,
      page: filters[:page]&.to_i,
      per_page: filters[:per_page]&.to_i
    )
  end

  def count
    scope.count
  end
end
