# frozen_string_literal: true

module SolidusSquare
  module CheckoutHelper
    def solidus_square_gateway
      SolidusSquare::Gateway.new(
        access_token: ENV['SQUARE_ACCESS_TOKEN'],
        environment: ENV['SQUARE_ENVIRONMENT'],
        location_id: ENV['SQUARE_LOCATION_ID'],
      )
    end
  end
end
