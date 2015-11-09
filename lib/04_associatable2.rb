require_relative '03_associatable'

module Associatable

  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options =
        through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      source_table = source_options.table_name

      foreign_key = self.send(through_options.foreign_key)

      results = DBConnection.execute(<<-SQL)
        SELECT
          #{source_table}.*
        FROM
          #{source_table}
        JOIN
          #{through_table} ON #{source_table}.#{source_options.primary_key} = #{through_table}.#{through_options.primary_key}
        WHERE
          #{through_table}.#{through_options.primary_key} = #{foreign_key}
      SQL

      source_options.model_class.parse_all(results).first
    end
  end
end
