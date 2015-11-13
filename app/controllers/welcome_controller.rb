class WelcomeController < ApplicationController
  def index
  end
  def search
    priceArray = params[:priceArray]
    priceArray[0]
    #average = priceArray.inject{ |sum, el| sum + el }.to_f / priceArray.size
  end
end
