# frozen_string_literal: true

module Slideck
  # Responsible for parsing metadata in YAML format
  #
  # @api private
  class MetadataParser
    # The symbolize names parameter
    #
    # @return [Symbol]
    #
    # @api private
    SYMBOLIZE_NAMES_PARAMETER = :symbolize_names
    private_constant :SYMBOLIZE_NAMES_PARAMETER

    # The permitted classes parameter
    #
    # @return [Symbol]
    #
    # @api private
    PERMITTED_CLASSES_PARAMETER = :permitted_classes
    private_constant :PERMITTED_CLASSES_PARAMETER

    # The whitelist classes parameter
    #
    # @return [Symbol]
    #
    # @api private
    WHITELIST_CLASSES_PARAMETER = :whitelist_classes
    private_constant :WHITELIST_CLASSES_PARAMETER

    # Create a MetadataParser instance
    #
    # @example
    #   MetadataParser.new(YAML, symbolize_names: true, permitted_classes: [])
    #
    # @param [YAML] yaml_parser
    #   the YAML parser
    # @param [Boolean] symbolize_names
    #   whether or not to symobolize names
    # @param [Array<Object>] permitted_classes
    #   the classes allowed to be deserialized
    #
    # @api public
    def initialize(yaml_parser, symbolize_names: nil, permitted_classes: nil)
      @yaml_parser = yaml_parser
      @symbolize_names = symbolize_names
      @permitted_classes = permitted_classes
    end

    # Parse metadata from content
    #
    # @example
    #   parser.parse("align: center\nfooter: footer content")
    #
    # @param [String] content
    #   the content to parse metadata from
    #
    # @return [Hash{String, Symbol => Object}]
    #   the deserialized metadata
    #
    # @api public
    def parse(content)
      parse_method = select_parse_method
      parse_params = parse_method_params(parse_method)
      arguments = parser_arguments(parse_params)
      options = parser_options(parse_params)
      metadata = @yaml_parser.send(parse_method, content, *arguments, **options)

      return metadata if symbolize_names?(options)

      @symbolize_names ? symbolize_keys(metadata) : metadata
    end

    private

    # Select metadata parse method
    #
    # @return [Symbol]
    #
    # @api private
    def select_parse_method
      @yaml_parser.respond_to?(:safe_load) ? :safe_load : :load
    end

    # Parse method parameters
    #
    # @param [Symbol] parse_method
    #   the parse method name
    #
    # @return [Array<Symbol>]
    #
    # @api private
    def parse_method_params(parse_method)
      @yaml_parser.method(parse_method).parameters.map(&:last)
    end

    # Generate parser arguments
    #
    # @param [Array<Symbol>] parse_method_params
    #   the parse method parameters
    #
    # @return [Array<Object>]
    #
    # @api private
    def parser_arguments(parse_method_params)
      return [] unless parse_method_params.include?(WHITELIST_CLASSES_PARAMETER)

      [@permitted_classes]
    end

    # Generate parser options
    #
    # @param [Array<Symbol>] parse_method_params
    #   the parse method parameters
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api private
    def parser_options(parse_method_params)
      {}.tap do |opts|
        if parse_method_params.include?(PERMITTED_CLASSES_PARAMETER)
          opts[:permitted_classes] = @permitted_classes
        end

        if parse_method_params.include?(SYMBOLIZE_NAMES_PARAMETER)
          opts[:symbolize_names] = @symbolize_names
        end
      end
    end

    # Check whether the YAML parser can symbolize names or not
    #
    # @param [Hash{Symbol => Object}] parse_options
    #   the parse method options
    #
    # @return [Boolean]
    #
    # @api private
    def symbolize_names?(parse_options)
      parse_options.key?(:symbolize_names)
    end

    # Symbolize metadata keys
    #
    # @param [Object] object
    #   the object with keys to symbolize
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api private
    def symbolize_keys(object)
      case object
      when Hash then symbolize_hash_keys(object)
      when Array then symbolize_array_hashes(object)
      else object
      end
    end

    # Symbolize hash keys
    #
    # @param [Hash] object
    #   the hash object with keys to symbolize
    #
    # @return [Hash{Symbol => Object}]
    #
    # @api private
    def symbolize_hash_keys(object)
      object.each_with_object({}) do |(key, val), new_hash|
        new_hash[key.to_sym] = symbolize_keys(val)
      end
    end

    # Symbolize array hash values
    #
    # @param [Array] object
    #   the array object with hash values to symbolize
    #
    # @return [Array<Object>]
    #
    # @api private
    def symbolize_array_hashes(object)
      object.each_with_object([]) do |val, new_array|
        new_array << symbolize_keys(val)
      end
    end
  end # MetadataParser
end # Slideck
