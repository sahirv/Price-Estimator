require 'rubygems'
require 'json'

class WelcomeController < ApplicationController
  def index
  end
  def search
    jsonResult = params[:priceArray]
    results = JSON.parse(jsonResult)
    @result = results[0]['title']
    #average = priceArray.inject{ |sum, el| sum + el }.to_f / priceArray.size
  end
end
