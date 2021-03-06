class QueryController < ApplicationController
  layout "main"

  def create
    @greper = Greper.new(params[:query])
    render :new and return if @greper.errors.present?
    @greper.get_reviews
  end
end
