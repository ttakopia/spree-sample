# frozen_string_literal: true

module Doorkeeper::Orm::ActiveRecord::Mixins
  module AccessToken
    extend ActiveSupport::Concern

    included do
      self.table_name = "#{table_name_prefix}oauth_access_tokens#{table_name_suffix}"

      include ::Doorkeeper::AccessTokenMixin

      belongs_to :application, class_name: Doorkeeper.config.application_class,
                               inverse_of: :access_tokens,
                               optional: true

      validates :token, presence: true, uniqueness: { case_sensitive: true }
      validates :refresh_token, uniqueness: { case_sensitive: true }, if: :use_refresh_token?

      # @attr_writer [Boolean, nil] use_refresh_token
      #   indicates the possibility of using refresh token
      attr_writer :use_refresh_token

      before_validation :generate_token, on: :create
      before_validation :generate_refresh_token,
                        on: :create, if: :use_refresh_token?
    end

    class_methods do
      # Searches for not revoked Access Tokens associated with the
      # specific Resource Owner.
      #
      # @param resource_owner [ActiveRecord::Base]
      #   Resource Owner model instance
      #
      # @return [ActiveRecord::Relation]
      #   active Access Tokens for Resource Owner
      #
      def active_for(resource_owner)
        where(resource_owner_id: resource_owner.id, revoked_at: nil)
      end

      def refresh_token_revoked_on_use?
        column_names.include?("previous_refresh_token")
      end
    end
  end
end
