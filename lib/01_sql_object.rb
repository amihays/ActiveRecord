require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    columns = DBConnection.execute2(<<-SQL).first
      SELECT
        *
      FROM
        #{table_name}
    SQL

    columns.map { |column| column.to_sym }
  end

  def self.finalize!
    columns.each do |column|
      define_method("#{column}") { attributes[column] }
      define_method("#{column}=") { |value| attributes[column] = value }
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    results = DBConnection.execute2(<<-SQL)[1..-1]
      SELECT
        *
      FROM
        #{table_name}
    SQL
    self.parse_all(results)
  end

  def self.parse_all(results)
    objectified = []
    results.each do |row|
      #row is a hash of column/value pairs
      objectified << self.new(row)
    end
    objectified
  end

  def self.find(id)
    result = DBConnection.execute(<<-SQL, id).first
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL
    return nil if result.nil?
    self.new(result)
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      attr_name = attr_name.to_sym
      unless self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end
      self.send("#{attr_name}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map { |column| self.send("#{column}") }
  end

  def insert
    table_name = self.class.table_name
    column_names = self.class.columns[1..-1].join(", ")
    n = attribute_values.length
    question_marks = (["?"] * (n - 1)).join(", ")
    DBConnection.execute(<<-SQL, *(attribute_values[1..-1]))
      INSERT INTO
        #{table_name} (#{column_names})
      VALUES
        (#{question_marks})
    SQL
    self.id = DBConnection.last_insert_row_id
  end

  def update
    table_name = self.class.table_name
    set_line = self.class.columns[1..-1].map { |column| "#{column} = ?" }.join(", ")
    DBConnection.execute(<<-SQL, *(attribute_values[1..-1]), attribute_values[0])
      UPDATE
        #{table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    if id
      update
    else
      insert
    end
  end
end
