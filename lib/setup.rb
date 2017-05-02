require_relative 'associatable'

DBConnection.reset

class Dog < SQLObject
  belongs_to :human, foreign_key: :owner_id

  has_many :toys, foreign_key: :dog_id

  finalize!
end

class Human < SQLObject
  self.table_name = 'humans'

  has_many :dogs, foreign_key: :owner_id

  finalize!
end

class Toy < SQLObject
  belongs_to :dog

  finalize!
end
