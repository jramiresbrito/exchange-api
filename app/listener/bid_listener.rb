# The BidListener is responsible to react to *:bid_buy* and *:bid_sell* events
# broadcasted by {BidConsumer}, every time the {Brokers} create a new {Bid}.
#
# @author Joao Victor Ramires Guimaraes Brito
class BidListener
  extend Wisper::Publisher

  # Listen the *:bid_buy* event. Then it try to find a matching {Bid} with
  # {Bid#operation} equal to *sell* and {Bid#value} lower or equal the received
  # value. If no matching {Bid} is found, a new {Bid} will be created having
  # {Bid#operation} equal to *buy*. However, if a {Bid} that comprises the
  # search criteria is found, it will check for it {Bid#amount}, then if:
  # - The found {Bid#amount} is lower or equal than the reiceived amount, it will destroy it and create a new {Bid} with the remaining amount.
  # - Otherwise, it will deduct the received amount from the found {Bid}.
  #
  # In all matching cases, it will create a new {Transaction} using the *transacted_amount* described above.
  # It will also broadcast a *:transaction_created* event which is listened by {RabbitmqListener}.
  #
  # * event: *:transaction_created*
  #
  # @param buyer_id [String]
  # @param asset_id [String]
  # @param amount [Integer]
  # @param value [Float]
  # @!scope class
  def self.bid_buy(buyer_id, asset_id, amount, value)
    matching_sell = Bid.where(asset_id: asset_id,
                              operation: 'sell',
                              value: { :$lte => value }).first

    if matching_sell
      transacted_amount = amount
      transacted_amount = matching_sell.amount if matching_sell.amount <= transacted_amount

      matching_sell.amount -= transacted_amount
      matching_sell.amount.zero? ? matching_sell.destroy! : matching_sell.save!
      seller_id = matching_sell.broker.id.to_s

      # the transaction is created using the max amount possible.
      Transaction.create!(buyer_id: buyer_id,
                          seller_id: seller_id,
                          asset_id: asset_id,
                          amount: transacted_amount,
                          value: matching_sell.value)

      # create a new bid only if the matching_sell.amount is less than the received amount
      # this new bid will have the remaining amount only
      if amount > transacted_amount
        amount -= transacted_amount
        Bid.create!(amount: amount, value: value, operation: 'buy', broker_id: buyer_id, asset_id: asset_id)
      end

      broadcast(:transaction_created, buyer_id, asset_id, transacted_amount)
    else
      Bid.create!(amount: amount, value: value, operation: 'buy', broker_id: buyer_id, asset_id: asset_id)
    end
  end

  # This is the selling version of {BidListener#bid_buy} method. The idea is the same.
  #
  # * event: *:transaction_created*
  #
  # @param seller_id [String]
  # @param asset_id [String]
  # @param amount [Integer]
  # @param value [Float]
  # @!scope class
  def self.bid_sell(seller_id, asset_id, amount, value)
    matching_buy = Bid.where(asset_id: asset_id,
                             operation: 'buy',
                             value: { :$gte => value }).first

    if matching_buy
      transacted_amount = amount
      transacted_amount = matching_buy.amount if matching_buy.amount <= transacted_amount

      matching_buy.amount -= transacted_amount
      matching_buy.amount.zero? ? matching_buy.destroy! : matching_buy.save!
      buyer_id = matching_buy.broker.id.to_s

      Transaction.create!(buyer_id: buyer_id,
                          seller_id: seller_id,
                          asset_id: asset_id,
                          amount: transacted_amount,
                          value: value)

      # create a new bid only if the matching_buy.amount is less than the received amount
      # this new bid will have the remaining amount only
      if amount > transacted_amount
        amount -= transacted_amount
        Bid.create!(amount: amount, value: value, operation: 'sell', broker_id: seller_id, asset_id: asset_id)
      end

      broadcast(:transaction_created, buyer_id, asset_id, transacted_amount)
    else
      Bid.create!(amount: amount, value: value, operation: 'sell', broker_id: seller_id, asset_id: asset_id)
    end
  end
end
