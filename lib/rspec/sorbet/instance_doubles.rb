# frozen_string_literal: true

require 'sorbet-runtime'

module RSpec
  module Sorbet
    module InstanceDoubles
      WHITELISTED_ERROR_MESSAGES = [
        'RSpec::Mocks::InstanceVerifyingDouble',
        'InstanceDouble'
      ].freeze

      def allow_instance_doubles!
        T::Configuration.inline_type_error_handler = proc do |error|
          inline_type_error_handler(error)
        end

        T::Configuration.call_validation_error_handler = proc do |signature, opts|
          call_validation_error_handler(signature, opts)
        end
      end

      private

      def inline_type_error_handler(error)
        raise error unless error.is_a?(TypeError) && message_is_whitelisted?(error.message)
      end

      def call_validation_error_handler(_signature, opts)
        raise TypeError, opts[:pretty_message] unless message_is_whitelisted?(opts[:message])
      end

      def message_is_whitelisted?(message)
        WHITELISTED_ERROR_MESSAGES.any? do |whitelisted_message|
          message.include?(whitelisted_message)
        end
      end
    end
  end
end
