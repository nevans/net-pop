# frozen_string_literal: true

require "net/imap"

module Net
  class POP
    SASL = Net::IMAP::SASL

    # Experimental
    #
    # Initialize with a block that runs a command, yielding for continuations.
    class SASLClientAdapter < SASL::ClientAdapter
      include SASL::ProtocolAdapters::POP

      RESPONSE_ERRORS = [
        POPError,
      ].freeze

      def initialize(...)
        super
        @command_proc ||= client.method(:send_command_with_continuations)
      end

      def authenticate(...)
        super
      rescue POPBadResponse
        drop_connection
        raise
      rescue SASL::AuthenticationIncomplete => error
        raise POPAuthenticationError, error.message
      end

      def host;                    client.address    end
      def response_errors;         RESPONSE_ERRORS   end
      def sasl_ir_capable?;        true              end
      def auth_capable?(mechanism) false             end # TODO: check CAPA
      def drop_connection;         client.finish     end
      def drop_connection!;        client.finish     end
    end
  end
end
