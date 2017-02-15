class MainController < ApplicationController
  def index
    @tree = TreeMap.new
  end
end
