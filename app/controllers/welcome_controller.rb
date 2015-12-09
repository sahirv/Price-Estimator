require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require "#{Rails.root}/app/models/Result Item/ResultItem.rb"

class WelcomeController < ApplicationController

  def index
  end

  def search

    @attributes = []

    if !(Dir.pwd.include? "public")
      Dir.chdir("public")
    end
    detailsFile = File.open("details.txt", "r")

    keyword = params[:keyword]
    numberOfResults = params[:numberOfResults]
    resultsArray = WelcomeController.GetResultsFromEbay(keyword, numberOfResults)
    

    # Get results from Ebay
    details = detailsFile.readlines.each do |detail|
    attributeName = ((detail.split("=")[0]).strip).tr('"', '')
    matchValue = ((detail.split("=")[1]).strip).tr('"', '')
    weightConstant = ((detail.split("=")[2]).strip).to_f

    @attributes.push(attributeName)

    resultsArray = WelcomeController.AssignWeightByAttributes(resultsArray, attributeName, matchValue, weightConstant)
    end

    @finalPrice = 0.0
    resultsArray.each do |result|
      @finalPrice += (result.priceUsd * result.weightTowardsFinal)
    end
    
    @results = resultsArray

  end

  # This method calls the Ebay Api's and returns their results in an array of hashes
  def self.GetResultsFromEbay( nameOfProduct, numberOfResults )

    resultsHashArray = []

    # Request results from the Ebay Finding Api with the nameOfProduct and numberOfEntries as the main parameters
    findingApiUrl = URI.parse("http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByKeywords&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=PriceApp-6d57-4fa0-bd01-63c74270c501&GLOBAL-ID=EBAY-US&RESPONSE-DATA-FORMAT=JSON&keywords=#{nameOfProduct}&paginationInput.entriesPerPage=#{numberOfResults}&_=1448672487493")
    findingApiResults = WelcomeController.SendHttpRequest(findingApiUrl)["findItemsByKeywordsResponse"][0]["searchResult"][0]["item"]
    itemIdArray = []

    findingApiResults.each do |result|
      itemId = result["itemId"][0]
      itemIdArray.push(itemId)
    end

    itemString = ""
    itemIdArray.each_with_index do |itemId, i|
      itemString += (itemId)
      if i != (itemIdArray.length - 1)
        itemString += (",")
      end
    end

    # Request results from the Ebay Shopping Api with the ItemId
    shoppingApiUrl = URI.parse(URI.unescape("http://open.api.ebay.com/shopping?callname=GetMultipleItems&responseencoding=JSON&appid=PriceApp-6d57-4fa0-bd01-63c74270c501&siteid=0&version=661&IncludeSelector=ItemSpecifics&ItemID=#{itemString}"))
    shoppingApiResults = WelcomeController.SendHttpRequest(shoppingApiUrl)["Item"]

    resultItems = []

    shoppingApiResults.each do |result|
      resultItems.push(ResultItem.new(
        1.0/shoppingApiResults.length,
        result,
        result["ConvertedCurrentPrice"]["Value"]))

    end

    return resultItems
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

    # This method takes in an array of ResultItems and alters the weight by weightConstant of each depending on whether
  # its value for the attributeName matches the matchValue
  def self.AssignWeightByAttributes(resultsArray, attributeName, matchValue, weightConstant)
    
    newArray = resultsArray.clone

    logger.debug newArray[0].detailsHash[attributeName]
    
    totalDepeciation = 0
    arrayOfMatchingIndices = []

    newArray.each_with_index do |result, i|
      if result.detailsHash[attributeName] != matchValue
        result.weightTowardsFinal -= weightConstant
        totalDepeciation += weightConstant
      else
        arrayOfMatchingIndices.push(i)
      end
    end

    appreciationPerMatch = totalDepeciation / arrayOfMatchingIndices.length
    arrayOfMatchingIndices.each do |index|
      newArray[index].weightTowardsFinal += appreciationPerMatch
    end

    return newArray

  end

end
