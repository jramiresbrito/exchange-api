# This consumer consumes the topic 'bid.operation' from
# *bolsadevalores* exchange. The it will find or create the related {Asset} and
# {Broker}. After this it broadcasts an *:bid_buy* or *:bid_sell* event, which
# is consumed by {BidListener}.
#
#
# ==== Events
# - *:bid_buy*
# - *:bid_sell*
#
# @author Joao Victor Ramires Guimaraes Brito
class BidConsumer
  include Wisper::Publisher
  include Hutch::Consumer

  consume 'bid.#'

  def process(message)
    operation = message.delivery_info.routing_key.split('.').last
    event = "bid_#{operation}".to_sym # bid_buy or bid_sell

    payload = JSON.parse(message.payload).deep_symbolize_keys
    bid = payload[:bid]
    amount = bid[:amount]
    value = bid[:value]
    asset = set_resource(bid, Asset)
    broker = set_resource(bid, Broker)

    broadcast(event, broker.id.to_s, asset.id.to_s, amount, value)
  end

  private

  def set_resource(bid, model)
    resource_data = bid[model.name.underscore.to_sym]
    resource_id = resource_data[:id][:$oid]
    resource = model.find_or_initialize_by(id: resource_id)
    resource.assign_attributes(resource_data.except(:id))

    resource.save!

    return resource
  end
end
