class EbayData

	# This method calls the Ebay Api's and returns their results in an array of hashes
  	def self.GetResultsFromEbay( nameOfProduct, numberOfResults )
	
  	  resultsHashArray = []
	
  	  # Request results from the Ebay Finding Api with the nameOfProduct and numberOfEntries as the main parameters
  	  findingApiUrl = URI.parse(URI.escape("http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsByKeywords&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=PriceApp-6d57-4fa0-bd01-63c74270c501&GLOBAL-ID=EBAY-US&RESPONSE-DATA-FORMAT=JSON&keywords=#{nameOfProduct}&paginationInput.entriesPerPage=#{numberOfResults}&_=1448672487493"))
  	  findingApiCall = WelcomeController.SendHttpRequest(findingApiUrl)
  	  # If call fails, return false
  	  if findingApiCall == "empty" || findingApiCall == "errorParsing"
  	    return false
  	  end
  	  findingApiResults = findingApiCall["findItemsByKeywordsResponse"][0]["searchResult"][0]["item"]
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
  	  shoppingApiCall = WelcomeController.SendHttpRequest(shoppingApiUrl)
  	  # If call fails, return false
  	  if shoppingApiCall == "empty" || shoppingApiCall == "errorParsing" || shoppingApiCall["Item"] == nil
  	    return false
  	  end
  	  shoppingApiResults = shoppingApiCall["Item"]
	
  	  resultItems = []
	
  	  shoppingApiResults.each do |result|
  	    resultItems.push(ResultItem.new(
  	      1.0/shoppingApiResults.length,
  	      result,
  	      result["ConvertedCurrentPrice"]["Value"]))
  	  end
	
  	  return resultItems
  	end

  	# This function gets the value from a name value pair in an Ebay details hash
  	def self.GetNameValueFromHash( detailsHash, name )
  		
  		nameValueList = detailsHash["ItemSpecifics"]["NameValueList"]

  		value = ""
  		nameFound = false;

  		# TODO: Replace this search with a more efficient one
  		nameValueList.each do |nameValuePair|
  			if nameValuePair["Name"] == name
  				value = nameValuePair["Value"][0]
  				nameFound = true
  				break
  			end
  		end

  		if !nameFound
  			return nil
  		else
  			return value
  		end
  	end
end