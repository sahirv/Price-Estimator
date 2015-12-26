require "#{Rails.root}/app/Ebay Data/EbayData.rb"

class ResultItem

	def initialize(weight, details, price)
		

		@weightTowardsFinal = weight	# The weight this item's price will contribute towards the final price returned
		@detailsHash = details	# This is an array of hash objects that contain details of the item
		@priceUsd = price	# The price of this item in US Dollars

	end

	attr_accessor :weightTowardsFinal
	attr_accessor :detailsHash
	attr_accessor :priceUsd

  	# This method takes in an array of ResultItems and alters the weight by weightConstant of each depending on whether
  	# its value for the attributeName matches the matchValue
  	def self.AssignWeightByAttributes(resultsArray, attributeName, matchValue, weightConstant)
	
  	  newArray = resultsArray.clone
  	  
  	  totalDepeciation = 0
  	  arrayOfMatchingIndices = []
	
  	  newArray.each_with_index do |result, i|
  	  	value = result.detailsHash[attributeName]
  	    if value != matchValue && !(value == nil && matchValue == EbayData.GetNameValueFromHash(result.detailsHash, attributeName))
  	      result.weightTowardsFinal -= weightConstant
  	      totalDepeciation += weightConstant
  	    else
  	      arrayOfMatchingIndices.push(i)
  	    end
  	  end
	
  	  if arrayOfMatchingIndices.length == 0
  	    for i in 0..(newArray.length-1)
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
