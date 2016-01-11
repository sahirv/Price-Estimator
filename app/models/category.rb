class Category < ActiveRecord::Base
  attr_accessible :category, :parent_category
  has_many :relations
  has_many :matchtests, :through => :relations
end
