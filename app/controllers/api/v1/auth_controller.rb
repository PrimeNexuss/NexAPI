# app/controllers/api/v1/auth_controller.rb
# ============================================================
#  INTENTIONALLY VULNERABLE — API2: Broken Authentication
#  - Weak JWT secret ("secret123")
#  - No token expiry
#  - No rate limiting (see API4)
# ============================================================

require 'jwt'

module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_request

      # POST /api/v1/auth/register
      def register
        user = User.new(user_params)
        if user.save
          render json: { message: "Registration successful", user: user_response(user) }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          # VULN API2: Weak secret, no expiry, no issued-at claim
          token = JWT.encode({ user_id: user.id, role: user.role }, "secret123", "HS256")
          render json: { token: token, user: user_response(user) }
        else
          render json: { error: "Invalid credentials" }, status: :unauthorized
        end
      end

      private

      def user_params
        # VULN API3: No strong parameter restriction — role is accepted
        params.permit(:name, :email, :password, :role, :balance)
      end

      def user_response(user)
        { id: user.id, name: user.name, email: user.email, role: user.role }
      end
    end
  end
end
