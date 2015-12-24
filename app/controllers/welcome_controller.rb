require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require "#{Rails.root}/app/models/Result Item/ResultItem.rb"
require "#{Rails.root}/app/models/Match Test/MatchTest.rb"
require "#{Rails.root}/app/Ebay Data/EbayData.rb"

class WelcomeController < ApplicationController

  def index
    if !(Dir.pwd.include? "public")
      Dir.chdir("public")
    end
    detailsFile = File.open("details.txt", "r")

    # read the details files to get the inputs for the category
    @inputs = []
    detailsFile.readlines.each_with_index do |detail, i|
      if i > 1
        inputId = (detail.split("|")[0]).strip
        inputString = (detail.split("|")[2]).strip
        inputType = inputString.split("=")[0].strip
        inputOptions = inputString.split("=")[1].strip
        inputDefault = inputString.split("=")[2].strip
        inputTitle = inputString.split("=")[3].strip

        input = {"inputId" => inputId, "inputTitle" => inputTitle, "inputType" => inputType, "inputOptions" => inputOptions, "inputDefault" => inputDefault}
        @inputs.push(input)
      end
    end

    @inputs = JSON.generate(@inputs)

    detailsFile.close
  end

  def search

    @error = ""
    @attributes = []
    matchTests = []

    # TODO: Instead of a file, get pre-stored data from a database and add an interface for changing that data
    if !(Dir.pwd.include? "public")
      Dir.chdir("public")
    end
    detailsFile = File.open("details.txt", "r")

    keyword = params[:keyword]
    categoryId = detailsFile.readline
    numberOfResults = detailsFile.readline.to_i

    # Read the category file and get the match tests
    detailsFile.readlines.each do |detail|
      id = (detail.split("|")[0]).strip
      matchTests.push(MatchTest.new(
        id, 
        ((detail.split("|")[1]).split("=")[0]).strip, 
        ((detail.split("|")[1]).split("=")[1]).strip.to_f,
        params[id]))
    end

    detailsFile.close

    # Get results from Ebay
    resultsArray = EbayData.GetResultsFromEbay(keyword, numberOfResults)
    if resultsArray == false
      @error = "Their was an error in the request. Please try again later."
      return
    end

    if resultsArray.length < numberOfResults
      weigthMultiplier = (numberOfResults / resultsArray.length.to_f)
      matchTests.each do |matchTest|
        matchTest.weightConstant *= weigthMultiplier
      end
    end

    # Run the algorithm for each match test
    matchTests.each do |matchTest|
      resultsArray = ResultItem.AssignWeightByAttributes(resultsArray, matchTest.attributeName, matchTest.matchValue, matchTest.weightConstant)
      @attributes.push(matchTest.attributeName)
    end

    # Calculate the final price using the final weights of each result
    @finalPrice = 0.0
    resultsArray.each do |result|
      @finalPrice += (result.priceUsd * result.weightTowardsFinal)
      logger.debug EbayData.GetNameValueFromHash(result.detailsHash, "Brand")
    end
    
    @results = resultsArray
  end

  def self.FilterByCondition (results, condition)

    # If the condition is new, return the average of all the prices
    if condition === "New"

      sumOfPricesDollars = 0 # this variable stores the sum of all the new products
      countOfNewProducts = 0 # this variable stores the count of new products
  		
      # For each product, add price to sum only if new
      results.each do |result|

  		  if result["condition"][0]["conditionDisplayName"][0] === "New"
          sumOfPricesDollars = sumOfPricesDollars # + the price of this product
          count = count + 1
        end

      end

        # Return the average by dividing the sum by the count
        averageofPricesDollars = sumOfPricesDollars / countOfNewProducts
        return averageofPricesDollars
    end

  end 
  # ---- end of FilterByCondition -------

  # This funtion returns the descriptions of all the items associated with the ItemId's in the array
  def self.RequestConditionDescription(itemIdArray)
    itemString = ""

    itemIdArray.each_with_index do |itemId, i|
      itemString += (itemId)
      if i != (itemIdArray.length - 1)
        itemString += (", ")
      end
    end

    url = URI.parse("http://open.api.ebay.com/shopping?callname=GetSingleItem&responseencoding=JSON&appid=PriceApp-6d57-4fa0-bd01-63c74270c501&siteid=0&version=661&IncludeSelector=ItemSpecifics&ItemID=#{itemString}")
    request = Net::HTTP::Get.new(url.request_uri)
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)

    if response.body.empty?
      return "error occured: nil response. " + url.to_s
    end

    begin
      responseParsed = JSON.parse(response.body)  
    rescue JSON::ParserError => e  
      return "error occured: response can't be parsed. url: #{url}"
    end 

    conditionDescription = responseParsed["Item"]["ConditionDescription"]

    return conditionDescription
  end

  # This method makes calls to all Http url's and returns the parsed JSON object
  def self.SendHttpRequest( url )
    request = Net::HTTP::Get.new(url.request_uri)
    http = Net::HTTP.new(url.host, url.port)
    response = http.request(request)

    if response.body.empty?
      return "empty"
    end

    begin
      responseParsed = JSON.parse(response.body)  
    rescue JSON::ParserError => e  
      return "errorParsing"
    end 

    return responseParsed
  end

end
