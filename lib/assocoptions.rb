require_relative 'searchable'

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
