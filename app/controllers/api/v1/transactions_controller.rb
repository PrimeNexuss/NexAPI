# app/controllers/api/v1/transactions_controller.rb
# ============================================================
#  INTENTIONALLY VULNERABLE — API1: Broken Object Level Authorization
#  - No ownership validation on transaction history
#  - Users can view other users' transactions
# ============================================================

module Api
  module V1
    class TransactionsController < ApplicationController
      before_action :authenticate_request

      # GET /api/v1/transactions
      # VULN API1: Returns all transactions, not just user's own
      def index
        transactions = Transaction.all
        render json: transactions.map { |t|
          {
            id: t.id,
            amount: t.amount,
            status: t.status,
            sender_account: t.sender_account.account_number,
            recipient_account: t.recipient_account.account_number,
            created_at: t.created_at
          }
        }
      end

      # GET /api/v1/transactions/:id
      # VULN API1: No ownership check on individual transaction
      def show
        transaction = Transaction.find(params[:id])
        render json: {
          id: transaction.id,
          amount: transaction.amount,
          status: transaction.status,
          sender_account: {
            account_number: transaction.sender_account.account_number,
            owner: transaction.sender_account.user.name
          },
          recipient_account: {
            account_number: transaction.recipient_account.account_number,
            owner: transaction.recipient_account.user.name
          },
          created_at: transaction.created_at
        }
      end
    end
  end
end
