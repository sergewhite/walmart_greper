require 'net/http'
require 'json'

class Greper
  attr_reader :errors, :product_id, :parsed_data
  POOL_SIZE   = 5  # max pool size
  PER_PAGE = 20
  def initialize options = {}
    @product_id = options[:id]
    @query = options[:query]
    @errors = []
    @pool    = [] # pool
    @parsed_data = {} # parsed data with page number
    @total_pages = 0
    @complete = false
    @errors << "ID can't be blank" if @product_id.blank?
  end

  def get_reviews
    total_reviews = get_total_reviews_count
    @total_pages = (total_reviews / PER_PAGE.to_f).ceil
    @total_pages = 1 if @total_pages < 1
    get_data if total_reviews > 0
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
      check_pool
      fetch_pages
      @parsed_data.sort
      # apply fulltext search
      #apply_filter
    end


    def check_pool
      # check the pool and reject finished tasks
      observer = Thread.new do
        loop do
          @pool.reject! { |thread| not thread.alive? }
          @complete && @pool.empty? && break
          sleep(1)
        end
      end
    end

    def fetch_pages
      # fetch pages in multiple streams
      @total_pages.times do |page|
        # do not create more threads than allowed, wallmart can probably ban by IP
        sleep(1) while @pool.size >= POOL_SIZE
        # add thread to a pool, send page number to it
        @pool << Thread.new(page + 1) { |p| fetch_data(p) }
      end
      # wait for all workers to finish
      sleep(1) while @pool.any?
      @complete = true
      # stop the pool observer
    end

    def fetch_data(page)
      url = URI.parse("http://www.walmart.com/reviews/api/product/#{@product_id}?limit=#{PER_PAGE}&page=#{page}&sort=helpful&showProduct=false")
      req = Net::HTTP::Get.new(url.to_s)
      res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      res = JSON.parse res.body
      @parsed_data[page] = Nokogiri.parse(res["reviewsHtml"]).search(".js-customer-review-text")
      #need more testing to identify the errors
      rescue
    end

    def apply_filter
      @parsed_data.sort.each do |page, data|
        # apply fulltext filter
      end
    end
end