# typed: strict
# frozen_string_literal: true

require "sorbet-runtime"

module RSpec
  module Sorbet
    module Doubles
      extend T::Sig
      extend T::Helpers

      requires_ancestor { Kernel }
      
      class <<self
        attr_accessor :defined
      end

      sig { void }
      def allow_doubles!
        return if RSpec::Sorbet::Doubles.defined
        
        T::Configuration.inline_type_error_handler = proc do |error|
          inline_type_error_handler(error)
        end

        @existing_handler = T.let(
          T::Configuration.instance_variable_get(:@call_validation_error_handler),
          T.nilable(T.proc.params(signature: T.untyped, opts: T::Hash[T.untyped, T.untyped]).void),
        )

        T::Configuration.call_validation_error_handler = proc do |signature, opts|
          call_validation_error_handler(signature, opts)
        end
        
        RSpec::Sorbet::Doubles.defined = true
      end

      alias_method :allow_instance_doubles!, :allow_doubles!

      private

      # rubocop:disable Layout/LineLength
      INLINE_DOUBLE_REGEX =
        T.let(/T.(?:let|cast): Expected type (?:T.(?<t_method>any|nilable|class_of)\()*(?<expected_types>[a-zA-Z0-9:: ,]*)(\))*, got (?:type .* with value )?#<(?<double_type>Instance|Class|Object)?Double([\(]|[ ])(?<doubled_type>[a-zA-Z0-9:: ,]*)(\))?/.freeze, Regexp)
      # rubocop:enable Layout/LineLength

      sig { params(signature: T.untyped, opts: T.untyped).void }
      def handle_call_validation_error(signature, opts)
        raise TypeError, opts[:pretty_message] unless @existing_handler

        @existing_handler.call(signature, opts)
      end

      sig { params(error: Exception).void }
      def inline_type_error_handler(error)
        case error
        when TypeError
          message = error.message
          return if unable_to_check_type_for_message?(message)

          raise error unless (match = message.match(INLINE_DOUBLE_REGEX))

          t_method = match[:t_method]
          expected_types = T.must(match[:expected_types]).split(",").map do |expected_type|
            Object.const_get(expected_type.strip)
          end
          double_type = match[:double_type]
          return if double_type.nil?

          doubled_type = Object.const_get(T.must(match[:doubled_type]))

          if double_type == "Class"
            raise error if t_method != "class_of"

            valid = expected_types.any? do |expected_type|
              doubled_type <= expected_type
            end
            raise error unless valid
          end

          valid = expected_types.any? do |expected_type|
            doubled_type.ancestors.include?(expected_type)
          end
          raise error unless valid
        else
          raise error
        end
      end

      sig { params(message: String).returns(T::Boolean) }
      def unable_to_check_type_for_message?(message)
        double_message_with_ellipsis?(message) ||
          typed_array_message?(message)
      end

      VERIFYING_DOUBLE_OR_DOUBLE =
        T.let(/(RSpec::Mocks::(Instance|Class|Object)VerifyingDouble|(Instance|Class|Object)?Double)/.freeze, Regexp)

      sig { params(message: String).returns(T::Boolean) }
      def double_message_with_ellipsis?(message)
        message.include?("...") && message.match?(VERIFYING_DOUBLE_OR_DOUBLE)
      end

      TYPED_ARRAY_MESSAGE = T.let(/got T::Array/.freeze, Regexp)

      sig { params(message: String).returns(T::Boolean) }
      def typed_array_message?(message)
        message.match?(TYPED_ARRAY_MESSAGE)
      end

      sig { params(signature: T.untyped, opts: T::Hash[T.untyped, T.untyped]).void }
      def call_validation_error_handler(signature, opts)
        should_raise = true

        message = opts.fetch(:pretty_message, opts.fetch(:message, ""))
        if message.match?(VERIFYING_DOUBLE_OR_DOUBLE)
          typing = opts[:type]
          value = opts[:value].is_a?(Array) ? opts[:value].first : opts[:value]
          target = value.instance_variable_get(:@doubled_module)&.target

          return if target.nil?

          case typing
          when T::Types::TypedArray, T::Types::TypedEnumerable
            typing = typing.type
          end

          case typing
          when T::Types::ClassOf
            should_raise = !(target <= typing.type)
          when T::Types::Simple
            should_raise = !target.ancestors.include?(typing.raw_type)
          when T::Types::Union
            valid = typing.types.any? do |type|
              next false unless type.respond_to?(:raw_type)

              target.ancestors.include?(type.raw_type)
            end
            should_raise = !valid
          else
            should_raise = !target.ancestors.include?(typing)
          end
        end

        handle_call_validation_error(signature, opts) if should_raise
      end
    end
  end
end
