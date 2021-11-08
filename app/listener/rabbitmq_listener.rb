# The RabbitmqListener class is responsible for publishing messages to
# RabbitMQ through
# {https://www.rabbitmq.com/tutorials/tutorial-five-ruby.html topic exchanging}.
#
# It uses the *bolsadevalores* topic to publish the payloads about events
# related to the brokers actions, such as bid creation or asset selling.
# Each event has a related routing key that follows this structure
# - *resource_type.action.key2.key3* - starting with the resource type
#   (e.g; transaction) and its related action (e.g.; created). Additionally,
#   it may have keys related to that specific event.
#
# The list of possible routing keys are described in the documentation of
# each method of this class.
#
# @author Joao Victor Ramires Guimaraes Brito
class RabbitmqListener
  # Publish the *transaction.created* topic having the *broker_id*, the *asset_id* and
  # the transacted *amount*. This topic is consumed by the
  # Brokers-API in order to create or increment a OwnedAsset resource.
  # Check TransactionCreatedConsumer in Brokers-API docs for more info.
  #
  # * routing key: transaction.created
  #
  # @param broker_id [String]
  # @param asset_id [String]
  # @param amount [Integer]
  # @!scope class
  def self.transaction_created(broker_id, asset_id, amount)
    payload = {
      transaction: {
        broker_id: broker_id, asset_id: asset_id, amount: amount
      }
    }.as_json

    publish("transaction.created", payload)
  end

  # Utility method to find and serialize the resource, and publish the proper
  # message to RabbitMQ
  #
  # @param object
  #   the object to be broadcasted
  # @param routing_key [String]
  # @!scope class
  def self.publish_resource(object, routing_key)
    broker = object.broker
    payload = resource_as_json(object, scope: broker, scope_name: :current_user)
    publish(routing_key, payload)
  end

  # @param resource
  #   the resource to be serialized
  # @param options
  #   serializer options for the resource's serializer class
  # @!scope class
  def self.resource_as_json(resource, options = {})
    serializer_klass = ActiveModel::Serializer.serializer_for(resource)
    serializer = serializer_klass.new(resource, options)
    adapter = ActiveModelSerializers::Adapter::Json.new(serializer, options)
    adapter.as_json
  end

  # Utility method that encapsulates the communication with the Hutch module
  #
  # @param routing_key [String]
  # @param payload [Hash]
  # @!scope class
  def self.publish(routing_key, payload)
    Hutch.connect
    Hutch.publish(routing_key, payload)
  end
end
