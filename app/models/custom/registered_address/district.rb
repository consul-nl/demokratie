class RegisteredAddress::District < ApplicationRecord
  has_many :registered_addresses, dependent: :restrict_with_exception,
    class_name: "RegisteredAddress", foreign_key: :registered_address_district_id

  default_scope { order(name: :asc) }

  def self.table_name_prefix
    "registered_address_"
  end
end
