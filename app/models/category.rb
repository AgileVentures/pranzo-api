class Category < ApplicationRecord
  has_and_belongs_to_many :products
  translates :promo
end
