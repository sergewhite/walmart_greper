class Greper

  def initialize options = {}
    @product_id = options[:id]
    @query = options[:query]
  end

  def get_reviews
    []
  end
end