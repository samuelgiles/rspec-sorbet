# frozen_string_literal: true

require 'sorbet-runtime'

module RSpec
  module Sorbet
    module InstanceDoubles
      def allow_instance_doubles!
        T::Configuration.inline_type_error_handler = proc do |error|
          inline_type_error_handler(error)
        end

        T::Configuration.call_validation_error_handler = proc do |signature, opts|
          call_validation_error_handler(signature, opts)
        end
      end

      private

      INLINE_INSTANCE_DOUBLE_REGEX =
        /T.let: Expected type (T.any\()?(?<expected_classes>[a-zA-Z:: ,]*)(\))?, got type (.*) with value #<InstanceDouble\((?<doubled_module>[a-zA-Z:: ,]*)\)/.freeze

      def inline_type_error_handler(error)
        case error
        when TypeError
          message = error.message
          return if instance_double_message_with_ellipsis?(message) || typed_array_message?(message)

          _, expected_types_string, doubled_module_string = (message.match(INLINE_INSTANCE_DOUBLE_REGEX) || [])[0..2]
          raise error unless expected_types_string && doubled_module_string

          expected_types = expected_types_string.split(',').map do |expected_type_string|
            Object.const_get(expected_type_string.strip)
          end
          doubled_module = Object.const_get(doubled_module_string)

          valid = expected_types.any? do |expected_type|
            doubled_module.ancestors.include?(expected_type)
          end

          raise error unless valid
        else
          raise error
        end
      end

      INSTANCE_VERIFYING_DOUBLE_OR_INSTANCE_DOUBLE =
        /(RSpec::Mocks::InstanceVerifyingDouble|InstanceDouble)/.freeze

      def instance_double_message_with_ellipsis?(message)
        message.include?('...') && message.match?(INSTANCE_VERIFYING_DOUBLE_OR_INSTANCE_DOUBLE)
      end

      TYPED_ARRAY_MESSAGE = /got T::Array/.freeze

      def typed_array_message?(message)
        message.match?(TYPED_ARRAY_MESSAGE)
      end

      def call_validation_error_handler(_signature, opts)
        should_raise = true

        message = opts.fetch(:pretty_message, opts.fetch(:message, ''))
        if message.match?(INSTANCE_VERIFYING_DOUBLE_OR_INSTANCE_DOUBLE)
          typing = opts[:type]
          value = opts[:value].is_a?(Array) ? opts[:value].first : opts[:value]
          target = value.instance_variable_get(:@doubled_module).target

          case typing
          when T::Types::TypedArray, T::Types::TypedEnumerable
            typing = typing.type
          end

          case typing
          when T::Types::Simple
            should_raise = !target.ancestors.include?(typing.raw_type)
          when T::Types::Union
            valid = typing.types.map(&:raw_type).any? do |type|
              target.ancestors.include?(type)
            end
            should_raise = !valid
          else
            should_raise = !target.ancestors.include?(typing)
          end
        end

        raise TypeError, opts[:pretty_message] if should_raise
      end
    end
  end
end
