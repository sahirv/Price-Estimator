class Relation < ActiveRecord::Base
  attr_accessible :category_id, :matchtest_id, :weight_constant
  belongs_to :category
  belongs_to :matchtest
end
