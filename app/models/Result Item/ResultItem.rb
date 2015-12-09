class ResultItem

	def initialize(weight, details, price)
		

		@weightTowardsFinal = weight	# The weight this item's price will contribute towards the final price returned
		@detailsHash = details	# This is an array of hash objects that contain details of the item
		@priceUsd = price	# The price of this item in US Dollars

	end

	attr_accessor :weightTowardsFinal
	attr_accessor :detailsHash
	attr_accessor :priceUsd

end
