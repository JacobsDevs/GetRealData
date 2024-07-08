class CreateSuburb < ActiveRecord::Migration[7.1]
  def change
    create_table :suburbs do |t|
      t.string :name
      t.string :domain_tag

      t.timestamps
    end
  end
end
