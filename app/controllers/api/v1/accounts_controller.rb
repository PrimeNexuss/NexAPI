# app/controllers/api/v1/accounts_controller.rb
# ============================================================
#  INTENTIONALLY VULNERABLE — API1: Broken Object Level Authorization
#  - No ownership validation on account resources
#  - Users can access other accounts' data by ID enumeration
# ============================================================

module Api
  module V1
    class AccountsController < ApplicationController
      before_action :authenticate_request

      # GET /api/v1/accounts/:id
      # VULN API1: No ownership check - any user can access any account
      def show
        account = Account.find(params[:id])
        render json: {
          id: account.id,
          account_number: account.account_number,
          account_type: account.account_type,
          balance: account.balance,
          owner: {
            id: account.user.id,
            name: account.user.name,
            email: account.user.email
          }
        }
      end

      # POST /api/v1/accounts/:id/transfer
      # VULN API6: No transfer limits or proper ownership validation
      def transfer
        account = Account.find(params[:id])
        recipient_account = Account.find_by(account_number: params[:recipient_account_number])
        
        unless recipient_account
          return render json: { error: "Recipient account not found" }, status: :not_found
        end

        amount = params[:amount].to_f
        if amount <= 0
          return render json: { error: "Invalid amount" }, status: :bad_request
        end

        if account.balance < amount
          return render json: { error: "Insufficient funds" }, status: :bad_request
        end

        # VULN API6: No transfer limits, no velocity checks
        account.balance -= amount
        recipient_account.balance += amount
        
        account.save
        recipient_account.save

        # Create transaction record
        Transaction.create!(
          sender_account: account,
          recipient_account: recipient_account,
          amount: amount,
          status: 'completed'
        )

        render json: {
          message: "Transfer successful",
          new_balance: account.balance,
          transaction_id: Transaction.last.id
        }
      end

      private

      def transfer_params
        params.permit(:recipient_account_number, :amount)
      end
    end
  end
end
