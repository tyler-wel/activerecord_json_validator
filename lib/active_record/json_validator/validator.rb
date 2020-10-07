# frozen_string_literal: true

class JsonValidator < ActiveModel::EachValidator
  def initialize(options)
    options.reverse_merge!(message: nil)
    options.reverse_merge!(schema: nil)
    options.reverse_merge!(options: {})
    @attributes = options[:attributes]

    super

    inject_setter_method(options[:class], @attributes)
  end

  # Validate the JSON value with a JSON schema path or String
  def validate_each(record, attribute, value)
    # Validate value with JSONSchemer
    schemer = JSONSchemer.schema(schema(record))
    json_errors = schemer.validate(validatable_value(value)).to_a
    errors = json_errors.each_with_object([]) { |err, arr| arr << JSONSchemer::Errors.pretty(err) }

    # Everything is good if we don’t have any errors and we got valid JSON value
    return if errors.empty? && record.send(:"#{attribute}_invalid_json").blank?

    errors.each do |error|
      record.errors.add(attribute, message, error: error)
    end
  end

  protected

  # Redefine the setter method for the attributes, since we want to
  # catch JSON parsing errors.
  def inject_setter_method(klass, attributes)
    attributes.each do |attribute|
      klass.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        attr_reader :"#{attribute}_invalid_json"

        define_method "#{attribute}=" do |args|
          begin
            @#{attribute}_invalid_json = nil
            args = ::ActiveSupport::JSON.decode(args) if args.is_a?(::String)
            super(args)
          rescue ActiveSupport::JSON.parse_error
            @#{attribute}_invalid_json = args
            super({})
          end
        end
      RUBY
    end
  end

  # Return a valid schema for JSON::Validator.fully_validate, recursively calling
  # itself until it gets a non-Proc/non-Symbol value.
  def schema(record, schema = nil)
    schema ||= options.fetch(:schema)

    case schema
      when Proc then schema(record, record.instance_exec(&schema))
      when Symbol then schema(record, record.send(schema))
      else schema
    end
  end

  def validatable_value(value)
    return value if value.is_a?(String)

    ::ActiveSupport::JSON.encode(value)
  end

  def message
    @message ||= options.fetch(:message) || :invalid_json
  end
end
