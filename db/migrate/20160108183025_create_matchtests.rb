class CreateMatchtests < ActiveRecord::Migration
  def change
    create_table :matchtests do |t|
      t.string :attribute_key
      t.string :attribute_name
      t.string :inputs
      t.string :info
      t.string :input_type
      t.string :default_value

      t.timestamps
    end
  end
end
