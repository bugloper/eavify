require_relative "eavify/version"

module Eavify
  extend ActiveSupport::Concern

  included do
    class_attribute :scope_fields, default: {}
    validate :validate_scope_fields
  end

  module ClassMethods
    def eavify(field_cfgs = [])
      field_cfgs.each do |cfg|
        scope = cfg[:scope].to_sym
        fields = cfg[:fields]
        validations = cfg[:validations] || {}

        self.scope_fields[scope] = {
          fields: fields,
          validations: validations
        }

        scope scope, -> {
          select(
            "id",
            "scope",
            "created_at",
            "updated_at",
            *fields.map do |field, data_type|
              case data_type
              when :text, :varchar
                "(cols->>'#{field}')::text as #{field}"
              when :decimal, :numeric
                "(cols->>'#{field}')::decimal as #{field}"
              when :integer
                "(cols->>'#{field}')::integer as #{field}"
              when :float, :double
                "(cols->>'#{field}')::float as #{field}"
              when :boolean
                "(cols->>'#{field}')::boolean as #{field}"
              when :date
                "(cols->>'#{field}')::date as #{field}"
              when :timestamp
                "(cols->>'#{field}')::timestamp as #{field}"
              when :timestamptz
                "(cols->>'#{field}')::timestamptz as #{field}"
              when :uuid
                "(cols->>'#{field}')::uuid as #{field}"
              else
                "(cols->>'#{field}')::text as #{field}"
              end
            end
          ).where(scope: scope)
        }

        fields.each do |field, _data_type|
          field_name = field.to_s
          define_method(field_name) do
            self.cols[field_name]
          end

          define_method("#{field_name}=") do |value|
            self.cols[field_name] = value
          end
        end
      end
    end
  end

  private

  def validate_scope_fields
    scope_data = self.class.scope_fields[scope.to_sym]
    return unless scope_data

    scope_data[:validations].each do |validation_type, fields|
      Array(fields).each do |field|
        next unless scope_data[:fields].keys.include?(field.to_s)

        case validation_type
        when :presence
          validates_presence_of field
        when :numericality
          validates_numericality_of field
        when :length
          validates_length_of field, maximum: fields[field][:maximum], message: fields[field][:message]
        when :inclusion
          validates_inclusion_of field, in: fields[field][:in], message: fields[field][:message]
        end
      end
    end
  end
end
