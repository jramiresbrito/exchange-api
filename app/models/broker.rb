# The Broker class represent the users that can negotiate {Asset} through the
# Exchange-API.
#
# @author Joao Victor Ramires Guimaraes Brito
#
#
# @!attribute name
#   @return [String]
#   The Broker name.
#
#   == Validations:
#   - presence
#   - unique
#   - has maximum length of 50
#
#
# @!attribute email
#   @return [String]
#   The Broker email.
#
#   == Validations:
#   - presence
#   - has maximum length of 255
#   - unique
#   - must be a valid email
class Broker
  include Mongoid::Document
  include Mongoid::Timestamps
  include LikeSearchable

  field :name, type: String
  field :email, type: String

  validates :name, presence: true, length: { maximum: 50 }, uniqueness: true
  validates :email, presence: true, length: { maximum: 255 },
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  before_save { self.email = email.downcase }
end
