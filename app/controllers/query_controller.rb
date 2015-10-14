class QueryController < ApplicationController
  layout "main"

  def create
    result = Greper.new(params[:query]).get_reviews
  end
end
