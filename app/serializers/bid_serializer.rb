class BidSerializer < ApplicationSerializer
  attributes :operation, :amount, :value

  belongs_to :asset
  belongs_to :broker
end
