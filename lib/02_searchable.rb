require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    table_name = self.table_name
    param_values = params.values
    where_line = params.keys.map{ |param| "#{param} = ?" }.join(" AND ")
    results = DBConnection.execute(<<-SQL, *param_values)
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        #{where_line}
    SQL
    results.map{ |result| self.new(result) }
  end
end

class SQLObject
  extend Searchable
end
