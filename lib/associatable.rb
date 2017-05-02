require_relative 'assocoptions'
require 'active_support/inflector'
require 'byebug'

module Associatable
  def belongs_to(name, options = {})
    define_method(name) do
      @options = BelongsToOptions.new(name, options)
      foreign_key_val = self.send(@options.foreign_key)
      target_class = @options.model_class
      target_class.where(id: foreign_key_val).first
    end
    self.assoc_options[name] = BelongsToOptions.new(name, options)
  end

  def has_many(name, options = {})
    define_method(name) do
      @options = HasManyOptions.new(name, self.class, options)
      primary_key_val = self.send(@options.primary_key)
      target_class = @options.model_class
      target_class.where(@options.foreign_key => primary_key_val)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      sql_query = <<-SQL
        SELECT
          #{source_options.model_class.table_name}.*
        FROM
          #{through_options.model_class.table_name}
        JOIN
          #{source_options.model_class.table_name}
        ON
          #{source_options.foreign_key} = #{source_options.model_class.table_name}.#{source_options.primary_key}
        WHERE
          #{through_options.model_class.table_name}.#{through_options.primary_key} = ?
      SQL

      source_options.model_class.new((DBConnection.execute(sql_query, self.owner_id)).first)
    end
  end
end

class SQLObject extend Associatable
end
