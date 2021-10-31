# This consumer consumes the topic
# 'bid.created' from
# *resource* exchange to perform a transaction
#
# @author Joao Victor Ramires Guimaraes Brito
class BidCreatedConsumer
  include Hutch::Consumer

  consume 'bid.created'

  def process(message)
    event = message.delivery_info.routing_key

    payload = JSON.parse(message.payload)

    p '=' * 100
    p payload
    p '=' * 100

    logger.info "Payload received"
  end
end
