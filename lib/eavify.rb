# frozen_string_literal: true

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

        # Define the scope with proper casting
        scope scope, lambda {
          select(
            'id',
            'scope',
            'created_at',
            'updated_at',
            *fields.map do |field, datatype|
              case datatype
              when :string
                "fields->>'#{field}' as #{field}"
              when :decimal, :numeric
                "(fields->>'#{field}')::numeric as #{field}"
              when :integer
                "(fields->>'#{field}')::integer as #{field}"
              when :array
                "fields->'#{field}' as #{field}"
              when :enum
                "fields->>'#{field}' as #{field}"
              else
                "fields->>'#{field}' as #{field}"
              end
            end
          ).where(scope: scope)
        }

        # Define attribute methods for each field
        fields.each do |field, type|
          field_name = field.to_s

          # Override read_attribute to handle both direct column access and fields JSON
          define_method(field_name) do
            # First try to get the value from attributes (scope-selected fields)
            direct_value = read_attribute(field_name)
            return direct_value unless direct_value.nil?

            # Fall back to fields JSON if direct access returns nil
            raw_value = fields&.[](field_name)
            return nil if raw_value.nil?

            case type
            when :array
              raw_value.is_a?(Array) ? raw_value : JSON.parse(raw_value.to_s)
            when :decimal, :numeric
              BigDecimal(raw_value.to_s)
            when :integer
              raw_value.to_i
            else
              raw_value
            end
          rescue StandardError
            raw_value
          end

          define_method("#{field_name}=") do |value|
            self.fields ||= {}

            processed_value = case type
                              when :array
                                begin
                                  value.is_a?(Array) ? value : JSON.parse(value)
                                rescue StandardError
                                  value
                                end
                              else
                                value
                              end

            self.fields[field_name] = processed_value
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
            validates_presence_of field, if: -> { self.scope == scope.to_s }
          when :numericality
            validates_numericality_of field, if: -> { self.scope == scope.to_s }
          when :length
            validates_length_of field,
                                maximum: field_list[field.to_s][:maximum],
                                message: field_list[field.to_s][:message],
                                if: -> { self.scope == scope.to_s }
          when :inclusion
            validates_inclusion_of field,
                                   in: field_list[field.to_s][:in],
                                   message: field_list[field.to_s][:message],
                                   if: -> { self.scope == scope.to_s }
          end
        end
      end
    end
  end

  private

  def validate_scope_fields
    # Add your custom validation logic here
    true
  end
end
