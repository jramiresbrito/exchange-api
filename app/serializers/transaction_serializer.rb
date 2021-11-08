class TransactionSerializer < ApplicationSerializer
  attributes :id, :amount, :value

  belongs_to :buyer
  belongs_to :seller
  belongs_to :asset
end
