require_relative 'eavify/version'

module Eavify
  extend ActiveSupport::Concern

  included do
    validate :validate_scope_fields
  end

  module ClassMethods
    def eavify(field_cfgs = [])
      field_cfgs.each do |cfg|
        scope = cfg[:scope].to_sym
        fields = cfg[:fields]
        validations = cfg[:validations] || {}

        scope scope, lambda {
          select(
            'id',
            'scope',
            'created_at',
            'updated_at',
            *fields.map do |field, datatype|
              case datatype
              when :text, :varchar
                "(fields->>'#{field}')::text as #{field}"
              when :decimal, :numeric
                "(fields->>'#{field}')::decimal as #{field}"
              when :integer
                "(fields->>'#{field}')::integer as #{field}"
              when :float, :double
                "(fields->>'#{field}')::float as #{field}"
              when :boolean
                "(fields->>'#{field}')::boolean as #{field}"
              when :date
                "(fields->>'#{field}')::date as #{field}"
              when :timestamp
                "(fields->>'#{field}')::timestamp as #{field}"
              when :timestamptz
                "(fields->>'#{field}')::timestamptz as #{field}"
              when :uuid
                "(fields->>'#{field}')::uuid as #{field}"
              else
                "(fields->>'#{field}')::text as #{field}"
              end
            end
          ).where(scope: scope)
        }

        fields.each do |field, _|
          field_name = field.to_s
          define_method(field_name) do
            fields[field_name]
          end

          define_method("#{field_name}=") do |value|
            fields[field_name] = value
          end
        end

        define_validations_for(scope, fields, validations)
      end
    end

    private

    def define_validations_for(scope, fields, validations)
      validations.each do |validation_type, field_list|
        Array(field_list).each do |field|
          next unless fields.keys.include?(field.to_s)

          case validation_type
          when :presence
            validates_presence_of field
          when :numericality
            validates_numericality_of field
          when :length
            validates_length_of field, maximum: field_list[field.to_s][:maximum], message: field_list[field.to_s][:message]
          when :inclusion
            validates_inclusion_of field, in: field_list[field.to_s][:in], message: field_list[field.to_s][:message]
          end
        end
      end
    end
  end

  private

  def validate_scope_fields
    # Implement 
    true
  end
end
