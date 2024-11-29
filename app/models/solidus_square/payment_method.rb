# frozen_string_literal: true

module SolidusSquare
  class PaymentMethod < Spree::PaymentMethod
    preference :access_token, :string
    preference :environment, :string, default: 'sandbox'
    preference :location_id, :string
    preference :app_id, :string
    preference :redirect_url, :string

    NOT_VOIDABLE_STATUSES = %w[CAPTURED VOIDED].freeze

    delegate :create_profile, to: :gateway

    def gateway_class
      ::SolidusSquare::Gateway
    end

    def payment_source_class
      ::SolidusSquare::PaymentSource
    end

    def payment_profiles_supported?
      true
    end

    def partial_name
      "square"
    end

    def try_void(payment)
      return false unless payment.source.can_void?(payment)

      gateway.void(payment.response_code, originator: payment)
    end

    def options
      {
        access_token: ENV['SQUARE_ACCESS_TOKEN'], # preferred_access_token,
        environment: ENV['SQUARE_ENVIRONMENT'], # preferred_environment&.to_sym,
        location_id: ENV['SQUARE_LOCATION_ID'], # preferred_location_id
      }
    end
  end
end
