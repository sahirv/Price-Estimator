class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :category
      t.string :parent_category

      t.timestamps
    end
  end
end
