class AddSuburbRefToProperties < ActiveRecord::Migration[7.1]
  def change
    add_reference :properties, :suburb, null: false, foreign_key: true
  end
end
