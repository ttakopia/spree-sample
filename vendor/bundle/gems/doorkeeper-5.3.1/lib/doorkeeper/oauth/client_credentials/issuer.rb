# frozen_string_literal: true

module Doorkeeper
  module OAuth
    class ClientCredentialsRequest < BaseRequest
      class Issuer
        attr_accessor :token, :validator, :error

        def initialize(server, validator)
          @server = server
          @validator = validator
        end

        def create(client, scopes, creator = Creator.new)
          if validator.valid?
            @token = create_token(client, scopes, creator)
            @error = :server_error unless @token
          else
            @token = false
            @error = validator.error
          end
          @token
        end

        private

        def create_token(client, scopes, creator)
          context = Authorization::Token.build_context(
            client,
            Doorkeeper::OAuth::CLIENT_CREDENTIALS,
            scopes,
          )
          ttl = Authorization::Token.access_token_expires_in(@server, context)

          creator.call(
            client,
            scopes,
            use_refresh_token: false,
            expires_in: ttl,
          )
        end
      end
    end
  end
end
