class CapacityController < ApplicationController

  respond_to :html, :json

  def index
  end

  def data
    respond_with JSON.parse(Summary.last.summary)
  end

  def summary
    respond_with JSON.parse(Summary.last.summary)
  end

end

