require_relative 'db_connection'
require_relative 'sql_object'
require 'byebug'

module Searchable
  def where(params)
    values = params.values
    cols = params.keys.map { |key| "#{key} = ?" }
    where_string = cols.join(" AND ")
    heredoc = <<-SQL
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL

    result = DBConnection.execute(heredoc, *values)

    # checks if we are calling on a relation or not, fetches correct classname if it is relation
    if self.class.to_s == 'Relation'
      className = self.collection[0].class
    else
      className = self
    end

    Relation.new(result.map{ |attrs| className.new(attrs) })
  end
end

class SQLObject extend Searchable
end

# takes in an array of model objects and extends searchable to allow where to be called on them
class Relation include Searchable
  attr_reader :table_name, :collection

  def initialize(model_objects)
    @collection = model_objects
    @table_name = model_objects[0].class.table_name
  end

  def [](index)
    @collection[index]
  end
end
