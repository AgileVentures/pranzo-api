class AddVendorToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :users, :vendor, null: true, foreign_key: true
  end
end
