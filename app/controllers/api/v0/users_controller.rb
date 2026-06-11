# app/controllers/api/v0/users_controller.rb
# ============================================================
#  INTENTIONALLY VULNERABLE — API9: Improper Inventory Management
#  - Legacy endpoint with no authentication
#  - Exposes user data without any access control
# ============================================================

module Api
  module V0
    class UsersController < ApplicationController
      # VULN API9: No authentication required - completely open endpoint
      skip_before_action :authenticate_request

      # GET /api/v0/users
      # VULN API9: Returns all users without any authentication
      def index
        users = User.all
        render json: users.map { |u|
          {
            id: u.id,
            name: u.name,
            email: u.email,
            role: u.role,
            balance: u.balance
          }
        }
      end
    end
  end
end
