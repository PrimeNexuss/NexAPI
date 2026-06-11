# app/controllers/api/v1/users_controller.rb
# ============================================================
#  INTENTIONALLY VULNERABLE — API1: Broken Object Level Authorization
#  - No ownership validation on user resources
#  - Users can access other users' data by ID enumeration
# ============================================================

module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_request

      # GET /api/v1/users/:id
      # VULN API1: No ownership check - any user can access any user's data
      def show
        user = User.find(params[:id])
        render json: {
          id: user.id,
          name: user.name,
          email: user.email,
          role: user.role,
          balance: user.balance
        }
      end

      # PATCH /api/v1/users/:id
      # VULN API3: Mass assignment - role can be escalated
      def update
        user = User.find(params[:id])
        if user.update(user_params)
          render json: { message: "User updated successfully", user: user_response(user) }
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        # VULN API3: No strong parameter restriction - role is accepted
        params.permit(:name, :email, :password, :role, :balance)
      end

      def user_response(user)
        { id: user.id, name: user.name, email: user.email, role: user.role }
      end
    end
  end
end
