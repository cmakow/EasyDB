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
    result.map{ |attrs| self.new(attrs) }
  end
end

class SQLObject extend Searchable
end
