class MatchTest

	def initialize(id, name, weight, value)
		
		@attributeId = id
		@attributeName = name
		@weightConstant = weight
		@matchValue = value

	end

	attr_accessor :attributeId
	attr_accessor :attributeName
	attr_accessor :weightConstant
	attr_accessor :matchValue
end
