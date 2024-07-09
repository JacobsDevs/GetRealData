class CreateProperty < ActiveRecord::Migration[7.1]
  def change
    create_table :properties do |t|
      t.string :link
      t.string :address
      t.string :beds
      t.string :baths
      t.string :cars
      t.string :land
      t.string :description
      t.string :price
      t.integer :high_price
      t.integer :low_price
			t.integer :single_price

      t.timestamps
    end
  end
end
