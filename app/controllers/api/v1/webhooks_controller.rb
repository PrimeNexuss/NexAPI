# app/controllers/api/v1/webhooks_controller.rb
# ============================================================
#  INTENTIONALLY VULNERABLE — API7: Server-Side Request Forgery
#  - No URL validation or allowlisting
#  - Internal network access possible via webhook URLs
# ============================================================

module Api
  module V1
    class WebhooksController < ApplicationController
      before_action :authenticate_request

      # POST /api/v1/webhooks
      # VULN API7: SSRF - accepts any URL without validation
      def create
        webhook_url = params[:url]
        
        unless webhook_url
          return render json: { error: "URL is required" }, status: :bad_request
        end

        # VULN API7: No URL validation, no allowlisting, no internal IP blocking
        begin
          response = Net::HTTP.get(URI(webhook_url))
          render json: {
            message: "Webhook registered successfully",
            url: webhook_url,
            response_preview: response[0..200] # Returns part of the response
          }
        rescue => e
          render json: { 
            error: "Failed to register webhook",
            details: e.message
          }, status: :bad_request
        end
      end

      private

      def webhook_params
        params.permit(:url)
      end
    end
  end
end
