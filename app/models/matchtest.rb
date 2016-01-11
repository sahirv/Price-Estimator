class Matchtest < ActiveRecord::Base
  attr_accessible :attribute_key, :attribute_name, :inputs, :info, :input_type, :default_value
  has_many :relations
  has_many :matchtests, :through => :relations
end
