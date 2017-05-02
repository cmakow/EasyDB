require_relative 'searchable'
require 'active_support/inflector'
require 'byebug'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @options = options
    @name = name

    unless @options[:class_name]
      self.class_name = name.to_s.camelcase
    else
      self.class_name = @options[:class_name]
    end
    unless @options[:primary_key]
      self.primary_key = :id
    else
      self.primary_key = @options[:primary_key]
    end
    unless @options[:foreign_key]
      self.foreign_key = "#{name}_id".to_sym
    else
      self.foreign_key = @options[:foreign_key]
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @options = options
    @name = name
    @self_class_name = self_class_name

    unless @options[:class_name]
      self.class_name = name.to_s.singularize.camelcase
    else
      self.class_name = @options[:class_name]
    end
    unless @options[:primary_key]
      self.primary_key = :id
    else
      self.primary_key = @options[:primary_key]
    end
    unless @options[:foreign_key]
      self.foreign_key = "#{self_class_name.to_s.downcase}_id".to_sym
    else
      self.foreign_key = @options[:foreign_key]
    end
  end
end

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
