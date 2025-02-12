class RecipientGroup < ApplicationRecord
  def self.base_kinds
    %i[projekt geo age indivudual_group]
  end
end
