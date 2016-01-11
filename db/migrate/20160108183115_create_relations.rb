class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations do |t|
      t.integer :category_id
      t.integer :matchtest_id
      t.decimal :weight_constant
      t.timestamps
    end
  end
end
