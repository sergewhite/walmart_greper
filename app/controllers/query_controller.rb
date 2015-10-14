class QueryController < ApplicationController
  layout "main"

  def create
    result = Greper.new(options).get_reviews
    binding.pry
    1+1
  end
end
