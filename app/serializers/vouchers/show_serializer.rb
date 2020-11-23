class Vouchers::ShowSerializer < ActiveModel::Serializer
  attributes :id, :code, :paid, :value, :current_value
  has_many :transactions

  def current_value
    object.value - object.transactions.count
  end
end