require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'

class SQLObject
  def self.columns
    @column_table ||= DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @cols = @column_table.first.map { |el| el.to_sym }
  end

  def self.finalize!
    self.columns.each do |col|
      self.send(:define_method, col) { self.attributes[col] } # getter methods defined
      accessor = "#{col}="
      self.send(:define_method, accessor) { |val| self.attributes[col] = val } # setter methods defined
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    unless @table_name.nil?
      @table_name
    else
      @table_name = "#{"#{self}".tableize}"
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        #{table_name}.*
      FROM
        #{table_name}
    SQL
    parse_all(results)
  end

  def self.first
    self.all[0]
  end

  def self.parse_all(results)
    result_array = []
    results.each do |result|
      result_array << self.new(result)
    end
    Relation.new(result_array)
  end

  def self.find(id)
    info = DBConnection.instance.get_first_row(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    if info.nil?
      nil
    else
      self.new(info)
    end
  end

  def initialize(params = {})
    params.each do |attr_name, val|
      if self.class.columns.include?(attr_name.to_sym)
        self.send("#{attr_name}=", val)
      else
        raise "unknown attribute '#{attr_name}'"
      end
    end
  end

  def attributes
    if @attributes.nil?
      @attributes = {}
    else
      @attributes
    end
  end

  def attribute_values
    self.class.columns.map { |col| self.send(col) }
  end

  def insert
    col_names = self.class.columns.map(&:to_s).join(", ")
    n = self.class.columns.length
    question_marks = "(#{(["?"] * n).join(", ")})"

    heredoc = <<-SQL
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        #{question_marks}
    SQL

    DBConnection.execute(heredoc, *self.attribute_values)
    self.id = DBConnection.instance.last_insert_row_id
  end

  def update
    set_string = self.class.columns.map(&:to_s).map { |attr_name| "#{attr_name} = ?"}.join(", ")

    heredoc = <<-SQL
      UPDATE
        #{self.class.table_name}
      SET
        #{set_string}
      WHERE
        id = #{self.id}
    SQL

    DBConnection.execute(heredoc, *self.attribute_values)
  end

  def save
    if self.id
      self.update
    else
      self.insert
    end
  end
end
