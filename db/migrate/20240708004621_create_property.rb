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
      t.string :high_price
      t.string :low_price

      t.timestamps
    end
  end
end