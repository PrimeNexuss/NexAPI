# app/controllers/api/admin/users_controller.rb
# ============================================================
#  INTENTIONALLY VULNERABLE — API5: Broken Function Level Authorization
#  - Admin endpoint accessible by non-admin users
#  - No role-based access control on admin routes
# ============================================================

module Api
  module Admin
    class UsersController < ApplicationController
      before_action :authenticate_request
      # VULN API5: No admin role check - any authenticated user can access

      # GET /api/admin/users
      # VULN API5: Returns all users including admin users
      def index
        users = User.all
        render json: users.map { |u|
          {
            id: u.id,
            name: u.name,
            email: u.email,
            role: u.role,
            balance: u.balance,
            created_at: u.created_at
          }
        }
      end

      # DELETE /api/admin/users/:id
      # VULN API5: Any user can delete any user including admins
      def destroy
        user = User.find(params[:id])
        user.destroy
        render json: { message: "User deleted successfully" }
      end
    end
  end
end
