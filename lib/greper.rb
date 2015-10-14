require 'net/http'
require 'json'

class Greper
  attr_reader :errors, :reviews

  def initialize options = {}
    @product_id = options[:id]
    @query = options[:query]
    @errors = []
    @reviews = []
    @errors << "ID can't be blank" if @product_id.blank?
  end

  def get_reviews
    total_reviews = get_total_reviews_count
    if total_reviews > 0
    end
  end

  private

    def get_total_reviews_count
      url = URI.parse("http://api.walmartlabs.com/v1/reviews/#{@product_id}?format=json&apiKey=q5n9pqab3aurxsr5kfrye44b")
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      res = JSON.parse res.body
      res.try("[]",'reviewStatistics').try('[]','totalReviewCount').to_i
    end

    def get_data
    end

end