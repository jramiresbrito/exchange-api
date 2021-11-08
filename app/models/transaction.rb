# The Transaction class represent an {Asset} ownership transfer. It happens when
# a {Bid} of type *buy* matches a *sell*. Every time a deal happens, the transaction
# record is stored in the database.
#
# @author Joao Victor Ramires Guimaraes Brito
#
#
# @!attribute buyer
#   @return [Broker]
#   An instance of a {Broker} that *bought* the {Asset}.
#
#   == Validations:
#   - presence
#
#
# @!attribute seller
#   @return [Broker]
#   An instance of a {Broker} that *sold* the {Asset}.
#
#   == Validations:
#   - presence
#
#
# @!attribute asset
#   @return [Asset]
#   An instance of the {Asset} being negotiated.
#
#   == Validations:
#   - presence
#
#
# @!attribute amount
#   @return [Integer]
#   The amount sold.
#
#   == Validations:
#   - presence
#   - must be a positive Integer
#
#
# @!attribute value
#   @return [Float]
#   The unit value.
#
#   == Validations:
#   - presence
#   - must be a positive float.
class Transaction
  include Mongoid::Document
  include Mongoid::Timestamps
  include LikeSearchable

  belongs_to :buyer, class_name: 'Broker'
  belongs_to :seller, class_name: 'Broker'
  belongs_to :asset

  field :amount, type: Integer
  field :value, type: Float

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :value, presence: true, numericality: { greater_than: 0.0 }
end
