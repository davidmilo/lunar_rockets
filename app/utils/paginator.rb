class Paginator
  def initialize(default_per_page:, min_per_page:, max_per_page:, default_page:)
    @default_per_page = default_per_page
    @default_page = default_page
    @min_per_page = min_per_page
    @max_per_page = max_per_page
  end

  def paginate(scope, page:, per_page:)
    return [] if scope.nil?

    per_page = (per_page || default_per_page).clamp(min_per_page..max_per_page)
    total_count = [scope.count, 1].max
    total_pages = (total_count / per_page.to_f).ceil
    page = (page || default_page).clamp(1..total_pages)

    records = scope
      .limit(per_page)
      .offset((page - 1) * per_page)

    {
      total_count:  total_count,
      total_pages:  total_pages,
      current_page: page,
      per_page:     per_page,
      records:      records
    }
  end

  private

  attr_reader :default_per_page,  :default_page, :min_per_page, :max_per_page
end
