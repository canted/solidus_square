# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SolidusSquare::CallbackActionsController', type: :request do
  around do |test|
    Rails.application.routes.draw do
      post 'square_checkout', to: 'solidus_square/callback_actions#square_checkout'
      mount Spree::Core::Engine, at: '/'
    end
    test.run
    Rails.application.reload_routes!
  end

  describe '#square_checkout', vcr: true do
    let(:order) { create(:order_with_line_items) }
    let(:payment_method) { create(:square_payment_method) }

    before do
      order.currency = "EUR"
      order.save
      allow(SolidusSquare.config).to receive(:square_access_token).and_return(ENV['SQUARE_ACCESS_TOKEN'])
      allow(SolidusSquare.config).to receive(:square_environment).and_return(ENV['SQUARE_ENVIRONMENT'])
      allow(SolidusSquare.config).to receive(:square_location_id).and_return(ENV['SQUARE_LOCATION_ID'])
      payment_method.preferred_redirect_url = "https://github.com"
      payment_method.save!
    end

    context "when respond to html", vcr: true do
      before do
        post square_checkout_path(order_number: order.number)
      end

      it "has http status 302" do
        expect(response.status).to eq(302)
      end
    end

    context "when respond to json", vcr: true do
      before do
        post square_checkout_path(order_number: order.number, format: :json)
      end

      it "returns the checkout_page_url" do
        expect(JSON.parse(response.body)).to include("redirect_url")
      end
    end
  end
end
