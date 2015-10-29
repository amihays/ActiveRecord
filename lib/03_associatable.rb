require_relative '02_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    self.model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || "#{name}_id".to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || name.to_s.camelcase
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    self.foreign_key = options[:foreign_key] ||
      "#{self_class_name.underscore}_id".to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || name.to_s.singularize.camelcase
  end
end

module Associatable
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

    define_method(name) do
      foreign_key = self.send(options.foreign_key)
      target_class = options.model_class
      target_class.where(options.primary_key => foreign_key).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      primary_key = self.send(options.primary_key)
      target_class = options.model_class
      target_class.where(options.foreign_key => primary_key)
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
